import { bootAdmin } from './app.js';
import { collections, listenCollection, toDate } from '../services/firestore-service.js';
import { formatDate } from '../services/ui.js';

let users = [];
let courses = [];
let notifications = [];
let activities = [];
let chart;

await bootAdmin('dashboard');

listenCollection(collections.users, (rows) => {
  users = rows;
  render();
});
listenCollection(collections.courses, (rows) => {
  courses = rows;
  render();
});
listenCollection(collections.notifications, (rows) => {
  notifications = rows;
  render();
});
listenCollection(collections.activityLog, (rows) => {
  activities = rows;
  renderActivities();
}, { orderBy: 'createdAt', limit: 8 });

function render() {
  const today = new Date();
  const todayCourses = courses.filter((course) => {
    const date = toDate(course.start_time || course.startTime);
    return date && date.toDateString() === today.toDateString();
  }).length;
  const unread = notifications.filter((item) => !item.isRead).length;
  const students = users.filter((user) => user.role !== 'admin');

  document.getElementById('statsGrid').innerHTML = [
    ['Etudiants', students.length],
    ['Cours', courses.length],
    ['Notifications', notifications.length],
    ["Cours aujourd'hui", todayCourses],
    ['Non lues', unread],
  ]
    .map(([label, value]) => `<article class="card stat-card"><span class="label">${label}</span><div class="value">${value}</div><span class="badge success">Live</span></article>`)
    .join('');

  renderChart(students.length, courses.length, notifications.length, todayCourses, unread);
}

function renderChart(studentsCount, coursesCount, notificationsCount, todayCourses, unread) {
  const canvas = document.getElementById('overviewChart');
  if (!canvas || !window.Chart) return;

  const data = [studentsCount, coursesCount, notificationsCount, todayCourses, unread];
  if (chart) {
    chart.data.datasets[0].data = data;
    chart.update();
    return;
  }

  chart = new Chart(canvas, {
    type: 'bar',
    data: {
      labels: ['Etudiants', 'Cours', 'Notifications', "Aujourd'hui", 'Non lues'],
      datasets: [{ label: 'Volume', data, backgroundColor: '#2563eb' }],
    },
    options: { responsive: true, plugins: { legend: { display: false } } },
  });
}

function renderActivities() {
  const list = document.getElementById('activityList');
  list.innerHTML = (activities.length ? activities : [])
    .map((item) => `<li><strong>${item.action || 'Action'}</strong><br><span>${item.entity || '-'} · ${formatDate(item.createdAt)}</span></li>`)
    .join('') || '<li>Aucune activite recente.</li>';
}
