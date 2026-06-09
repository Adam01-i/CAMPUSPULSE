import {
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-auth.js';
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
} from 'https://www.gstatic.com/firebasejs/10.12.5/firebase-firestore.js';
import { auth, db } from './firebase.js';
import { adminConfig } from '../firebase/firebase-config.js';

export async function loginAdmin(email, password) {
  const credential = await signInWithEmailAndPassword(auth, email, password);
  const profile = await getAdminProfile(credential.user.uid);

  if (!isAdminProfile(profile)) {
    await signOut(auth);
    throw new Error("Votre compte n'a pas les permissions administrateur.");
  }

  await setDoc(
    doc(db, 'users', credential.user.uid),
    {
      lastAdminLoginAt: serverTimestamp(),
      email: credential.user.email,
    },
    { merge: true },
  );

  return credential.user;
}

export async function logoutAdmin() {
  await signOut(auth);
  window.location.href = 'login.html';
}

export function watchAdminAuth({ requireAuth = true } = {}) {
  return new Promise((resolve) => {
    onAuthStateChanged(auth, async (user) => {
      if (!user) {
        if (requireAuth) window.location.href = 'login.html';
        resolve(null);
        return;
      }

      const profile = await getAdminProfile(user.uid);
      if (!isAdminProfile(profile)) {
        await signOut(auth);
        if (requireAuth) window.location.href = 'login.html';
        resolve(null);
        return;
      }

      resolve({ user, profile });
    });
  });
}

export async function getAdminProfile(uid) {
  const snapshot = await getDoc(doc(db, 'users', uid));
  return snapshot.exists() ? { id: snapshot.id, ...snapshot.data() } : null;
}

export function isAdminProfile(profile) {
  if (!profile) return false;
  const hasRole =
    profile[adminConfig.adminRoleField] === adminConfig.adminRoleValue ||
    profile.isAdmin === true;
  const isActive =
    !profile[adminConfig.activeStatusField] ||
    profile[adminConfig.activeStatusField] === adminConfig.activeStatusValue ||
    profile.active === true;

  return hasRole && isActive;
}
