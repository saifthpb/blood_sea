import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

// Firebase Admin SDK configuration
const firebaseAdminConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID || 'blood-sea-57816',
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
};

// Initialize Firebase Admin SDK (singleton pattern)
function initializeFirebaseAdmin() {
  if (getApps().length === 0) {
    try {
      const app = initializeApp({
        credential: cert(firebaseAdminConfig),
        projectId: firebaseAdminConfig.projectId,
      });
      
      console.log('✅ Firebase Admin SDK initialized successfully');
      return app;
    } catch (error) {
      console.error('❌ Firebase Admin SDK initialization failed:', error);
      throw error;
    }
  }
  return getApps()[0];
}

// Initialize the app
const adminApp = initializeFirebaseAdmin();

// Export Firebase Admin services
export const adminAuth = getAuth(adminApp);
export const adminDb = getFirestore(adminApp);
export const adminMessaging = getMessaging(adminApp);

export default adminApp;
