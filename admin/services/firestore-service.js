import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js';
import { db } from './firebase.js';

export const collections = {
  users: 'users',
  courses: 'courses',
  notifications: 'notifications',
  dispatchQueue: 'notificationDispatchQueue',
  reminderQueue: 'courseReminderQueue',
  activityLog: 'adminActivityLog',
};

export function listenCollection(name, callback, options = {}) {
  const constraints = [];
  if (options.orderBy) constraints.push(orderBy(options.orderBy, options.direction || 'desc'));
  if (options.limit) constraints.push(limit(options.limit));

  return onSnapshot(query(collection(db, name), ...constraints), (snapshot) => {
    callback(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
  });
}

export async function getAll(name) {
  const snapshot = await getDocs(collection(db, name));
  return snapshot.docs.map((item) => ({ id: item.id, ...item.data() }));
}

export async function createDoc(name, data, forcedId) {
  const payload = { ...data, createdAt: serverTimestamp(), updatedAt: serverTimestamp() };
  if (forcedId) {
    await setDoc(doc(db, name, forcedId), { id: forcedId, ...payload }, { merge: true });
    return forcedId;
  }

  const reference = await addDoc(collection(db, name), payload);
  await updateDoc(reference, { id: reference.id });
  return reference.id;
}

export async function updateEntity(name, id, data) {
  await updateDoc(doc(db, name, id), { ...data, updatedAt: serverTimestamp() });
}

export async function deleteEntity(name, id) {
  await deleteDoc(doc(db, name, id));
}

export async function getEntity(name, id) {
  const snapshot = await getDoc(doc(db, name, id));
  return snapshot.exists() ? { id: snapshot.id, ...snapshot.data() } : null;
}

export async function markAllNotificationsRead() {
  const snapshot = await getDocs(collection(db, collections.notifications));
  const batch = writeBatch(db);
  snapshot.docs.forEach((item) => batch.update(item.ref, { isRead: true, updatedAt: serverTimestamp() }));
  await batch.commit();
}

export async function getCoursesForDate(date) {
  const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  const snapshot = await getDocs(
    query(
      collection(db, collections.courses),
      where('start_time', '>=', Timestamp.fromDate(start)),
      where('start_time', '<', Timestamp.fromDate(end)),
      orderBy('start_time', 'asc'),
    ),
  );

  return snapshot.docs.map((item) => ({ id: item.id, ...item.data() }));
}

export async function logActivity(action, entity, entityId, details = {}) {
  await addDoc(collection(db, collections.activityLog), {
    action,
    entity,
    entityId,
    details,
    createdAt: serverTimestamp(),
  });
}

export function toDate(value) {
  if (!value) return null;
  if (value.toDate) return value.toDate();
  if (value instanceof Date) return value;
  return new Date(value);
}

export function toTimestamp(value) {
  return Timestamp.fromDate(value instanceof Date ? value : new Date(value));
}
