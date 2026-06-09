import {
  doc,
  serverTimestamp,
  setDoc,
  Timestamp,
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js';
import { db } from './firebase.js';
import { adminConfig } from '../firebase/firebase-config.js';
import { collections, getCoursesForDate, toDate } from './firestore-service.js';

const timers = new Map();

export async function createNotification({
  id,
  title,
  body,
  type = 'admin',
  courseId = null,
  extra = {},
  queueFcm = false,
}) {
  const notificationId = id || `admin_${Date.now()}`;
  await setDoc(doc(db, collections.notifications, notificationId), {
    id: notificationId,
    title,
    body,
    type,
    isRead: false,
    courseId,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...extra,
  });

  if (queueFcm) {
    await setDoc(doc(db, collections.dispatchQueue, notificationId), {
      notificationId,
      title,
      body,
      type,
      courseId,
      topic: adminConfig.fcmTopic,
      status: 'pending',
      createdAt: serverTimestamp(),
    });
  }

  return notificationId;
}

export async function onCourseCreated(courseId, course) {
  await createNotification({
    id: `new_course_${courseId}`,
    title: 'Nouveau cours ajouté',
    body: `${course.title} - Salle ${course.room}`,
    type: 'newCourse',
    courseId,
    queueFcm: true,
  });

  await queueCourseReminder(courseId, course);
}

export async function onCourseRoomChanged(courseId, before, after) {
  if (!before || before.room === after.room) return;

  await createNotification({
    id: `room_changed_${courseId}_${safeId(after.room)}`,
    title: 'Changement de salle',
    body: `La salle du cours ${after.title} a changé. Nouvelle salle : ${after.room}`,
    type: 'roomChanged',
    courseId,
    queueFcm: true,
    extra: { oldRoom: before.room, newRoom: after.room },
  });
}

export async function onCourseDeleted(courseId, course) {
  await createNotification({
    id: `course_cancelled_${courseId}_${Date.now()}`,
    title: 'Cours annulé',
    body: `Le cours ${course.title} a été annulé.`,
    type: 'courseCancelled',
    courseId,
    queueFcm: true,
  });
}

export async function queueCourseReminder(courseId, course) {
  const startAt = toDate(course.start_time || course.startTime);
  if (!startAt) return;

  const reminderAt = new Date(startAt.getTime() - 15 * 60 * 1000);
  const reminderId = `course_reminder_${courseId}_${startAt.getTime()}`;

  await setDoc(doc(db, collections.reminderQueue, reminderId), {
    id: reminderId,
    courseId,
    title: 'Rappel de cours',
    body: `Votre cours ${course.title} commence dans 15 minutes.`,
    type: 'reminder',
    reminderAt: Timestamp.fromDate(reminderAt),
    status: 'scheduled',
    createdAt: serverTimestamp(),
  });

  scheduleBrowserReminder(reminderId, courseId, course, reminderAt);
}

export function scheduleBrowserReminder(reminderId, courseId, course, reminderAt) {
  if (timers.has(reminderId)) clearTimeout(timers.get(reminderId));

  const delay = reminderAt.getTime() - Date.now();
  if (delay <= 0) return;

  timers.set(
    reminderId,
    setTimeout(async () => {
      await createNotification({
        id: reminderId,
        title: 'Rappel de cours',
        body: `Votre cours ${course.title} commence dans 15 minutes.`,
        type: 'reminder',
        courseId,
      });
      timers.delete(reminderId);
    }, Math.min(delay, 2147483647)),
  );
}

export async function createDailyPlanningNotification(date = new Date()) {
  const courses = await getCoursesForDate(date);
  const lines = courses
    .map((course) => {
      const start = toDate(course.start_time || course.startTime);
      return `- ${course.title} ${formatTime(start)}`;
    })
    .join('\n');
  const dateId = [
    date.getFullYear(),
    `${date.getMonth() + 1}`.padStart(2, '0'),
    `${date.getDate()}`.padStart(2, '0'),
  ].join('');

  return createNotification({
    id: `daily_planning_${dateId}`,
    title: 'Planning du jour',
    body: `Vous avez ${courses.length} cours aujourd'hui :\n${lines}`,
    type: 'reminder',
    extra: { courseCount: courses.length },
  });
}

export function startDailyPlanningScheduler() {
  const now = new Date();
  const next = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 7, 0, 0);
  if (next <= now) next.setDate(next.getDate() + 1);

  setTimeout(async () => {
    await createDailyPlanningNotification(new Date());
    startDailyPlanningScheduler();
  }, next.getTime() - now.getTime());
}

function formatTime(date) {
  if (!date) return '';
  return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' });
}

function safeId(value) {
  return String(value || '').trim().replace(/[^a-zA-Z0-9_-]+/g, '_');
}
