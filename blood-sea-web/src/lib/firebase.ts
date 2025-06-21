import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyAk5y9bkxzRN9CKKQJVOwhIDoR3vzF0CsU",
  authDomain: "blood-sea-57816.firebaseapp.com",
  projectId: "blood-sea-57816",
  storageBucket: "blood-sea-57816.firebasestorage.app",
  messagingSenderId: "965946138871",
  appId: "1:965946138871:web:37b1116e09d4b986d2b3f2",
  measurementId: "G-SEN977GTK6"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);

export default app;
