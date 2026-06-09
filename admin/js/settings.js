import { bootAdmin } from './app.js';
import { firebaseConfig } from '../firebase/firebase-config.js';
import { applyTheme, toast } from '../services/ui.js';

await bootAdmin('settings');

document.getElementById('firebaseConfigView').textContent = JSON.stringify(
  {
    projectId: firebaseConfig.projectId,
    authDomain: firebaseConfig.authDomain,
    storageBucket: firebaseConfig.storageBucket,
    messagingSenderId: firebaseConfig.messagingSenderId,
  },
  null,
  2,
);

document.getElementById('themeSelect').value = localStorage.getItem('admin-theme') || 'light';
document.getElementById('pageSize').value = localStorage.getItem('admin-page-size') || 10;

document.getElementById('savePrefs').addEventListener('click', () => {
  applyTheme(document.getElementById('themeSelect').value);
  localStorage.setItem('admin-page-size', document.getElementById('pageSize').value);
  toast('Preferences enregistrees.');
});
