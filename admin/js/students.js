import { bootAdmin } from './app.js';
import {
  collections,
  createDoc,
  deleteEntity,
  listenCollection,
  logActivity,
  updateEntity,
} from '../services/firestore-service.js';
import { closeAllModals, openModal, setLoading, toast } from '../services/ui.js';
import { exportExcel, exportPdf } from '../services/export-service.js';

let rows = [];
let filtered = [];
let editing = null;
let page = 1;
const pageSize = Number(localStorage.getItem('admin-page-size') || 10);

await bootAdmin('students');

listenCollection(collections.users, (items) => {
  rows = items.filter((item) => item.role !== 'admin');
  renderFilters();
  render();
});

document.getElementById('addStudent').addEventListener('click', () => {
  editing = null;
  document.getElementById('studentForm').reset();
  document.getElementById('studentId').value = '';
  document.getElementById('studentModalTitle').textContent = 'Ajouter un etudiant';
  openModal('studentModal');
});

['searchInput', 'departmentFilter', 'statusFilter'].forEach((id) => {
  document.getElementById(id).addEventListener('input', () => {
    page = 1;
    render();
  });
});

document.getElementById('studentForm').addEventListener('submit', async (event) => {
  event.preventDefault();
  setLoading(true);

  const id = document.getElementById('studentId').value;
  const payload = studentPayload();

  try {
    if (id) {
      await updateEntity(collections.users, id, payload);
      await logActivity('Modification etudiant', 'users', id, payload);
      toast('Etudiant modifie.');
    } else {
      const newId = await createDoc(collections.users, { ...payload, role: 'student' });
      await logActivity('Creation etudiant', 'users', newId, payload);
      toast('Etudiant ajoute.');
    }
    closeAllModals();
  } catch (error) {
    toast(error.message || 'Enregistrement impossible.', 'error');
  } finally {
    setLoading(false);
  }
});

document.getElementById('studentsTable').addEventListener('click', async (event) => {
  const button = event.target.closest('button[data-action]');
  if (!button) return;

  const row = rows.find((item) => item.id === button.dataset.id);
  if (!row) return;

  if (button.dataset.action === 'edit') fillForm(row);
  if (button.dataset.action === 'delete' && confirm('Supprimer cet etudiant ?')) {
    await deleteEntity(collections.users, row.id);
    await logActivity('Suppression etudiant', 'users', row.id);
    toast('Etudiant supprime.');
  }
});

document.getElementById('exportExcel').addEventListener('click', () => exportExcel(filtered.map(exportRow), 'etudiants'));
document.getElementById('exportPdf').addEventListener('click', () => exportPdf('etudiants', filtered.map(exportRow)));

function render() {
  const search = document.getElementById('searchInput').value.toLowerCase();
  const department = document.getElementById('departmentFilter').value;
  const status = document.getElementById('statusFilter').value;

  filtered = rows.filter((item) => {
    const haystack = `${item.firstName || ''} ${item.lastName || ''} ${item.email || ''} ${item.studentNumber || item.matricule || ''}`.toLowerCase();
    return (!search || haystack.includes(search)) &&
      (!department || item.department === department) &&
      (!status || (item.status || 'active') === status);
  });

  const start = (page - 1) * pageSize;
  const pageRows = filtered.slice(start, start + pageSize);
  document.getElementById('studentsTable').innerHTML = pageRows.map(rowTemplate).join('');
  renderPagination();
}

function renderFilters() {
  const select = document.getElementById('departmentFilter');
  const current = select.value;
  const departments = [...new Set(rows.map((item) => item.department).filter(Boolean))].sort();
  select.innerHTML = '<option value="">Tous les departements</option>' + departments.map((item) => `<option>${item}</option>`).join('');
  select.value = current;
}

function renderPagination() {
  const pages = Math.max(1, Math.ceil(filtered.length / pageSize));
  document.getElementById('pagination').innerHTML = `
    <button class="button secondary" ${page <= 1 ? 'disabled' : ''} id="prevPage">Precedent</button>
    <span class="badge">Page ${page}/${pages}</span>
    <button class="button secondary" ${page >= pages ? 'disabled' : ''} id="nextPage">Suivant</button>
  `;
  document.getElementById('prevPage')?.addEventListener('click', () => { page--; render(); });
  document.getElementById('nextPage')?.addEventListener('click', () => { page++; render(); });
}

function rowTemplate(item) {
  const status = item.status || 'active';
  return `<tr>
    <td><img class="avatar" src="${item.photoUrl || 'assets/avatar.svg'}" alt=""></td>
    <td>${item.lastName || item.nom || '-'}</td>
    <td>${item.firstName || item.prenom || '-'}</td>
    <td>${item.email || '-'}</td>
    <td>${item.studentNumber || item.matricule || '-'}</td>
    <td>${item.department || '-'}</td>
    <td>${item.program || item.filiere || '-'}</td>
    <td>${item.level || item.niveau || '-'}</td>
    <td><span class="badge ${status === 'active' ? 'success' : 'danger'}">${status}</span></td>
    <td><button class="button secondary" data-action="edit" data-id="${item.id}">Modifier</button> <button class="button danger" data-action="delete" data-id="${item.id}">Supprimer</button></td>
  </tr>`;
}

function fillForm(item) {
  editing = item;
  document.getElementById('studentModalTitle').textContent = 'Modifier un etudiant';
  document.getElementById('studentId').value = item.id;
  document.getElementById('lastName').value = item.lastName || item.nom || '';
  document.getElementById('firstName').value = item.firstName || item.prenom || '';
  document.getElementById('email').value = item.email || '';
  document.getElementById('studentNumber').value = item.studentNumber || item.matricule || '';
  document.getElementById('department').value = item.department || '';
  document.getElementById('program').value = item.program || item.filiere || '';
  document.getElementById('level').value = item.level || item.niveau || '';
  document.getElementById('photoUrl').value = item.photoUrl || '';
  document.getElementById('status').value = item.status || 'active';
  openModal('studentModal');
}

function studentPayload() {
  return {
    lastName: document.getElementById('lastName').value.trim(),
    firstName: document.getElementById('firstName').value.trim(),
    email: document.getElementById('email').value.trim(),
    studentNumber: document.getElementById('studentNumber').value.trim(),
    department: document.getElementById('department').value.trim(),
    program: document.getElementById('program').value.trim(),
    level: document.getElementById('level').value.trim(),
    photoUrl: document.getElementById('photoUrl').value.trim(),
    status: document.getElementById('status').value,
  };
}

function exportRow(item) {
  return {
    nom: item.lastName || item.nom || '',
    prenom: item.firstName || item.prenom || '',
    email: item.email || '',
    matricule: item.studentNumber || item.matricule || '',
    departement: item.department || '',
    filiere: item.program || item.filiere || '',
    niveau: item.level || item.niveau || '',
    statut: item.status || 'active',
  };
}
