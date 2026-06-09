import { bootAdmin } from './app.js';
import {
  collections,
  createDoc,
  deleteEntity,
  listenCollection,
  logActivity,
  toDate,
  toTimestamp,
  updateEntity,
} from '../services/firestore-service.js';
import {
  onCourseCreated,
  onCourseDeleted,
  onCourseRoomChanged,
  queueCourseReminder,
} from '../services/automation-service.js';
import { closeAllModals, formatDate, openModal, setLoading, toast } from '../services/ui.js';

let rows = [];
let filtered = [];
let page = 1;
const pageSize = Number(localStorage.getItem('admin-page-size') || 10);

await bootAdmin('courses');

listenCollection(collections.courses, (items) => {
  rows = items.sort((a, b) => (toDate(a.start_time) || 0) - (toDate(b.start_time) || 0));
  render();
});

document.getElementById('addCourse').addEventListener('click', () => {
  document.getElementById('courseForm').reset();
  document.getElementById('courseId').value = '';
  document.getElementById('courseModalTitle').textContent = 'Creer un cours';
  openModal('courseModal');
});

['searchInput', 'dateFilter', 'teacherFilter', 'roomFilter'].forEach((id) => {
  document.getElementById(id).addEventListener('input', () => { page = 1; render(); });
});

document.getElementById('courseForm').addEventListener('submit', async (event) => {
  event.preventDefault();
  setLoading(true);
  const id = document.getElementById('courseId').value;
  const payload = coursePayload();

  try {
    if (id) {
      const before = rows.find((item) => item.id === id);
      await updateEntity(collections.courses, id, payload);
      await onCourseRoomChanged(id, before, payload);
      await queueCourseReminder(id, payload);
      await logActivity('Modification cours', 'courses', id, payload);
      toast('Cours modifie.');
    } else {
      const newId = await createDoc(collections.courses, payload);
      await onCourseCreated(newId, payload);
      await logActivity('Creation cours', 'courses', newId, payload);
      toast('Cours cree avec notification.');
    }
    closeAllModals();
  } catch (error) {
    toast(error.message || 'Enregistrement impossible.', 'error');
  } finally {
    setLoading(false);
  }
});

document.getElementById('coursesTable').addEventListener('click', async (event) => {
  const button = event.target.closest('button[data-action]');
  if (!button) return;
  const course = rows.find((item) => item.id === button.dataset.id);
  if (!course) return;

  if (button.dataset.action === 'edit') fillCourse(course);
  if (button.dataset.action === 'delete' && confirm('Supprimer ce cours ?')) {
    await onCourseDeleted(course.id, course);
    await deleteEntity(collections.courses, course.id);
    await logActivity('Suppression cours', 'courses', course.id);
    toast('Cours supprime et notification creee.');
  }
});

function render() {
  const search = document.getElementById('searchInput').value.toLowerCase();
  const date = document.getElementById('dateFilter').value;
  const teacher = document.getElementById('teacherFilter').value.toLowerCase();
  const room = document.getElementById('roomFilter').value.toLowerCase();

  filtered = rows.filter((item) => {
    const start = toDate(item.start_time || item.startTime);
    const dateMatch = !date || (start && start.toISOString().slice(0, 10) === date);
    const text = `${item.title || ''} ${item.teacher || ''} ${item.room || ''}`.toLowerCase();
    return (!search || text.includes(search)) &&
      dateMatch &&
      (!teacher || String(item.teacher || '').toLowerCase().includes(teacher)) &&
      (!room || String(item.room || '').toLowerCase().includes(room));
  });

  const startIndex = (page - 1) * pageSize;
  document.getElementById('coursesTable').innerHTML = filtered.slice(startIndex, startIndex + pageSize).map(rowTemplate).join('');
  renderPagination();
}

function rowTemplate(item) {
  const start = toDate(item.start_time || item.startTime);
  const end = toDate(item.end_time || item.endTime);
  return `<tr>
    <td>${item.title || '-'}</td>
    <td><span class="badge">${item.room || '-'}</span></td>
    <td>${item.teacher || '-'}</td>
    <td>${formatDate(start).split(' ')[0]}</td>
    <td>${time(start)}</td>
    <td>${time(end)}</td>
    <td><button class="button secondary" data-action="edit" data-id="${item.id}">Modifier</button> <button class="button danger" data-action="delete" data-id="${item.id}">Supprimer</button></td>
  </tr>`;
}

function renderPagination() {
  const pages = Math.max(1, Math.ceil(filtered.length / pageSize));
  document.getElementById('pagination').innerHTML = `<button class="button secondary" ${page <= 1 ? 'disabled' : ''} id="prevPage">Precedent</button><span class="badge">Page ${page}/${pages}</span><button class="button secondary" ${page >= pages ? 'disabled' : ''} id="nextPage">Suivant</button>`;
  document.getElementById('prevPage')?.addEventListener('click', () => { page--; render(); });
  document.getElementById('nextPage')?.addEventListener('click', () => { page++; render(); });
}

function fillCourse(item) {
  const start = toDate(item.start_time || item.startTime);
  const end = toDate(item.end_time || item.endTime);
  document.getElementById('courseModalTitle').textContent = 'Modifier un cours';
  document.getElementById('courseId').value = item.id;
  document.getElementById('title').value = item.title || '';
  document.getElementById('room').value = item.room || '';
  document.getElementById('teacher').value = item.teacher || '';
  document.getElementById('date').value = start ? start.toISOString().slice(0, 10) : '';
  document.getElementById('startTime').value = start ? start.toTimeString().slice(0, 5) : '';
  document.getElementById('endTime').value = end ? end.toTimeString().slice(0, 5) : '';
  openModal('courseModal');
}

function coursePayload() {
  const date = document.getElementById('date').value;
  const start = new Date(`${date}T${document.getElementById('startTime').value}:00`);
  const end = new Date(`${date}T${document.getElementById('endTime').value}:00`);
  return {
    title: document.getElementById('title').value.trim(),
    room: document.getElementById('room').value.trim(),
    teacher: document.getElementById('teacher').value.trim(),
    start_time: toTimestamp(start),
    end_time: toTimestamp(end),
    status: 'scheduled',
    isCancelled: false,
  };
}

function time(date) {
  return date ? date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) : '-';
}
