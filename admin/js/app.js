import { watchAdminAuth } from '../services/auth-service.js';
import { bindModalDismiss, initShell } from '../services/ui.js';
import { startDailyPlanningScheduler } from '../services/automation-service.js';

export async function bootAdmin(page) {
  const session = await watchAdminAuth({ requireAuth: true });
  if (!session) return null;

  initShell(page);
  bindModalDismiss();
  startDailyPlanningScheduler();
  document.body.classList.add('ready');
  return session;
}
