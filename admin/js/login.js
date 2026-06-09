import { loginAdmin, watchAdminAuth } from '../services/auth-service.js';
import { setLoading, toast } from '../services/ui.js';

watchAdminAuth({ requireAuth: false }).then((session) => {
  if (session) window.location.href = 'dashboard.html';
});

document.getElementById('loginForm').addEventListener('submit', async (event) => {
  event.preventDefault();
  setLoading(true);

  try {
    await loginAdmin(
      document.getElementById('email').value.trim(),
      document.getElementById('password').value,
    );
    window.location.href = 'dashboard.html';
  } catch (error) {
    toast(error.message || 'Connexion impossible.', 'error');
  } finally {
    setLoading(false);
  }
});
