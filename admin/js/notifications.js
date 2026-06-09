import { bootAdmin } from "./app.js";
import {
  collections,
  createDoc,
  deleteEntity,
  listenCollection,
  logActivity,
  markAllNotificationsRead,
  updateEntity,
} from "../services/firestore-service.js";
import {
  closeAllModals,
  formatDate,
  openModal,
  setLoading,
  toast,
} from "../services/ui.js";

let rows = [];
let filtered = [];
let page = 1;
const pageSize = Number(localStorage.getItem("admin-page-size") || 10);

await bootAdmin("notifications");

listenCollection(
  collections.notifications,
  (items) => {
    rows = items;
    render();
  },
  { orderBy: "createdAt" },
);

document.getElementById("addNotification").addEventListener("click", () => {
  document.getElementById("notificationForm").reset();
  document.getElementById("notificationId").value = "";
  document.getElementById("notificationModalTitle").textContent =
    "Creer une notification";
  openModal("notificationModal");
});

// document.getElementById("markAllRead").addEventListener("click", async () => {
//   await markAllNotificationsRead();
//   await logActivity("Notifications toutes lues", "notifications", "all");
//   toast("Notifications marquees comme lues.");
// });

["searchInput", "typeFilter", "readFilter"].forEach((id) => {
  document.getElementById(id).addEventListener("input", () => {
    page = 1;
    render();
  });
});

document
  .getElementById("notificationForm")
  .addEventListener("submit", async (event) => {
    event.preventDefault();
    setLoading(true);

    const id = document.getElementById("notificationId").value;
    const payload = {
      title: document.getElementById("title").value.trim(),
      body: document.getElementById("body").value.trim(),
      type: document.getElementById("type").value,
      isRead: document.getElementById("isRead").value === "true",
    };

    try {
      if (id) {
        await updateEntity(collections.notifications, id, payload);
        await logActivity(
          "Modification notification",
          "notifications",
          id,
          payload,
        );
        toast("Notification modifiee.");
      } else {
        const newId = await createDoc(collections.notifications, payload);
        await logActivity(
          "Creation notification",
          "notifications",
          newId,
          payload,
        );
        toast("Notification creee.");
      }
      closeAllModals();
    } catch (error) {
      toast(error.message || "Enregistrement impossible.", "error");
    } finally {
      setLoading(false);
    }
  });

document
  .getElementById("notificationsTable")
  .addEventListener("click", async (event) => {
    const button = event.target.closest("button[data-action]");
    if (!button) return;
    const item = rows.find((row) => row.id === button.dataset.id);
    if (!item) return;

    if (button.dataset.action === "edit") fillNotification(item);
    if (button.dataset.action === "read") {
      await updateEntity(collections.notifications, item.id, { isRead: true });
      toast("Notification lue.");
    }
    if (
      button.dataset.action === "delete" &&
      confirm("Supprimer cette notification ?")
    ) {
      await deleteEntity(collections.notifications, item.id);
      await logActivity("Suppression notification", "notifications", item.id);
      toast("Notification supprimee.");
    }
  });

function render() {
  const search = document.getElementById("searchInput").value.toLowerCase();
  const type = document.getElementById("typeFilter").value;
  const read = document.getElementById("readFilter").value;

  filtered = rows.filter((item) => {
    const text = `${item.title || ""} ${item.body || ""}`.toLowerCase();
    return (
      (!search || text.includes(search)) &&
      (!type || item.type === type) &&
      (!read || String(Boolean(item.isRead)) === read)
    );
  });

  const start = (page - 1) * pageSize;
  document.getElementById("notificationsTable").innerHTML = filtered
    .slice(start, start + pageSize)
    .map(rowTemplate)
    .join("");
  renderPagination();
}

function rowTemplate(item) {
  return `<tr>
    <td>${item.title || "-"}</td>
    <td>${(item.body || "-").slice(0, 90)}</td>
    <td>${formatDate(item.createdAt)}</td>
    <td><span class="badge">${item.type || "admin"}</span></td>
    <td><button class="button secondary" data-action="edit" data-id="${item.id}">Modifier</button> <button class="button danger" data-action="delete" data-id="${item.id}">Supprimer</button></td>
  </tr>`;
}

function renderPagination() {
  const pages = Math.max(1, Math.ceil(filtered.length / pageSize));
  document.getElementById("pagination").innerHTML =
    `<button class="button secondary" ${page <= 1 ? "disabled" : ""} id="prevPage">Precedent</button><span class="badge">Page ${page}/${pages}</span><button class="button secondary" ${page >= pages ? "disabled" : ""} id="nextPage">Suivant</button>`;
  document.getElementById("prevPage")?.addEventListener("click", () => {
    page--;
    render();
  });
  document.getElementById("nextPage")?.addEventListener("click", () => {
    page++;
    render();
  });
}

function fillNotification(item) {
  document.getElementById("notificationModalTitle").textContent =
    "Modifier une notification";
  document.getElementById("notificationId").value = item.id;
  document.getElementById("title").value = item.title || "";
  document.getElementById("body").value = item.body || "";
  document.getElementById("type").value = item.type || "admin";
  document.getElementById("isRead").value = String(Boolean(item.isRead));
  openModal("notificationModal");
}
