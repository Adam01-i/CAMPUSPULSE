import { logoutAdmin } from './auth-service.js';

export function initShell(activePage) {
  const sidebar = document.querySelector('[data-sidebar]');
  const header = document.querySelector('[data-header]');
  const toggle = document.querySelector('[data-menu-toggle]');

  if (sidebar) {
    sidebar.innerHTML = navItems()
      .map(
        (item) => `
          <a class="nav-link ${item.id === activePage ? 'active' : ''}" href="${item.href}">
            <span>${item.icon}</span><span>${item.label}</span>
          </a>
        `,
      )
      .join('');
  }

  if (header) {
    header.innerHTML = `
      <div>
        <p class="eyebrow">CampusPulse Admin</p>
        <h1>${pageTitle(activePage)}</h1>
      </div>
      <div class="header-actions">
        <button class="icon-button" data-theme-toggle title="Changer le theme">◐</button>
        <button class="button ghost" data-logout>Deconnexion</button>
      </div>
    `;
  }

  document.querySelector('[data-logout]')?.addEventListener('click', logoutAdmin);
  document.querySelector('[data-theme-toggle]')?.addEventListener('click', toggleTheme);
  toggle?.addEventListener('click', () => document.body.classList.toggle('sidebar-open'));
  applyTheme(localStorage.getItem('admin-theme') || 'light');
}

export function toast(message, type = 'success') {
  const root = document.querySelector('[data-toast-root]') || createToastRoot();
  const item = document.createElement('div');
  item.className = `toast ${type}`;
  item.textContent = message;
  root.appendChild(item);
  setTimeout(() => item.remove(), 3600);
}

export function setLoading(isLoading) {
  document.querySelector('[data-loader]')?.classList.toggle('visible', isLoading);
}

export function openModal(id) {
  document.getElementById(id)?.classList.add('visible');
}

export function closeModal(id) {
  document.getElementById(id)?.classList.remove('visible');
}

export function closeAllModals() {
  document.querySelectorAll('.modal.visible').forEach((modal) => modal.classList.remove('visible'));
}

export function formatDate(value) {
  if (!value) return '-';
  const date = value.toDate ? value.toDate() : new Date(value);
  return date.toLocaleString('fr-FR', { dateStyle: 'medium', timeStyle: 'short' });
}

export function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  localStorage.setItem('admin-theme', theme);
}

export function toggleTheme() {
  applyTheme(document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark');
}

export function bindModalDismiss() {
  document.addEventListener('click', (event) => {
    if (event.target.matches('[data-close-modal]')) closeAllModals();
    if (event.target.classList.contains('modal')) event.target.classList.remove('visible');
  });
}

function createToastRoot() {
  const root = document.createElement('div');
  root.dataset.toastRoot = '';
  root.className = 'toast-root';
  document.body.appendChild(root);
  return root;
}

function navItems() {
  return [
    { id: 'dashboard', label: 'Dashboard', href: 'dashboard.html', icon: '▦' },
    { id: 'students', label: 'Etudiants', href: 'students.html', icon: '◉' },
    { id: 'courses', label: 'Cours', href: 'courses.html', icon: '▤' },
    { id: 'notifications', label: 'Notifications', href: 'notifications.html', icon: '◌' },
    { id: 'settings', label: 'Parametres', href: 'settings.html', icon: '⚙' },
  ];
}

function pageTitle(activePage) {
  return {
    dashboard: 'Tableau de bord',
    students: 'Gestion des etudiants',
    courses: 'Gestion des cours',
    notifications: 'Notifications',
    settings: 'Parametres',
  }[activePage] || 'Administration';
}
