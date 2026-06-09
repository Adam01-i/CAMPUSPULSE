# CampusPulse Admin Web

Interface d'administration statique pour Firebase Authentication et Cloud Firestore.

## Structure

```text
admin/
├── index.html
├── login.html
├── dashboard.html
├── students.html
├── courses.html
├── notifications.html
├── settings.html
├── css/styles.css
├── js/
├── services/
├── firebase/firebase-config.js
├── firestore.rules.example
└── assets/
```

## Collections Firestore

```text
users/{uid}
  email: string
  firstName: string
  lastName: string
  studentNumber: string
  department: string
  program: string
  level: string
  photoUrl: string
  status: "active" | "inactive"
  role: "student" | "admin"

courses/{courseId}
  title: string
  room: string
  teacher: string
  start_time: Timestamp
  end_time: Timestamp
  status: "scheduled" | "cancelled"
  isCancelled: bool

notifications/{notificationId}
  id: string
  title: string
  body: string
  createdAt: Timestamp
  updatedAt: Timestamp
  type: "newCourse" | "reminder" | "roomChanged" | "courseCancelled" | "admin"
  isRead: bool
  courseId?: string

notificationDispatchQueue/{notificationId}
  notificationId: string
  title: string
  body: string
  type: string
  topic: "campus_notifications"
  status: "pending"

courseReminderQueue/{reminderId}
  courseId: string
  title: string
  body: string
  reminderAt: Timestamp
  status: "scheduled"
```

## Installation locale

Depuis la racine du projet:

```bash
python3 -m http.server 8080
```

Puis ouvrir:

```text
http://localhost:8080/admin/login.html
```

L'application utilise le Firebase Web SDK depuis CDN, donc elle doit être servie en HTTP/HTTPS. Eviter `file://`.

## Creer le premier administrateur

1. Creer un utilisateur dans Firebase Authentication.
2. Dans Firestore, creer ou modifier `users/{uid}`:

```json
{
  "email": "admin@campuspulse.edu",
  "role": "admin",
  "status": "active",
  "firstName": "Admin",
  "lastName": "CampusPulse"
}
```

## Deploiement Firebase Hosting

Exemple de configuration:

```json
{
  "hosting": {
    "public": "admin",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  }
}
```

Puis:

```bash
firebase deploy --only hosting
```

## Automatisations

- Creation de cours: cree une notification `newCourse`, une entree `courseReminderQueue`, et une demande FCM dans `notificationDispatchQueue`.
- Modification de salle: cree une notification `roomChanged`.
- Suppression de cours: cree une notification `courseCancelled`.
- Planning quotidien 07h00: genere `daily_planning_YYYYMMDD` lorsque l'admin web est ouvert.
- Rappel 15 minutes: programme un timer navigateur et stocke aussi l'intention dans `courseReminderQueue`.

Important: pour garantir les rappels et FCM lorsque personne n'a l'admin ouvert, ajouter une Cloud Function planifiee qui consomme `courseReminderQueue` et `notificationDispatchQueue` avec Firebase Admin SDK.

## Securite Firestore

Utiliser `firestore.rules.example` comme base. Les points critiques:

- L'admin web ne doit pas accorder les droits par lui-même.
- Les droits viennent de Firestore Rules via `users/{uid}.role == "admin"`.
- Les suppressions d'activites admin sont interdites.
- L'envoi FCM final doit rester cote backend, jamais depuis le navigateur.

## Notes de production

- Le CRUD etudiant cree des profils Firestore. La creation de comptes Firebase Auth pour les etudiants doit se faire par invitation, Cloud Function ou console admin securisee.
- Les exports Excel/PDF utilisent SheetJS/jsPDF depuis CDN.
- Les pages sont modulaires et sans build step.
