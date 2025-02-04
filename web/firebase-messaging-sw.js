// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAk5y9bkxzRN9CKKQJVOwhIDoR3vzF0CsU",
  authDomain: "blood-sea-57816.firebaseapp.com",
  projectId: "blood-sea-57816",
  storageBucket: "blood-sea-57816.firebasestorage.app",
  messagingSenderId: "965946138871",
  appId: "1:965946138871:web:37b1116e09d4b986d2b3f2"
});

const messaging = firebase.messaging();
