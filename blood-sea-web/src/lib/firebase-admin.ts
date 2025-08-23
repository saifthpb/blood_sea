import { initializeApp, getApps, cert, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

// Initialize Firebase Admin SDK (singleton pattern)
function initializeFirebaseAdmin() {
  if (getApps().length === 0) {
    try {
      let app;
      
      // Try to use service account file if GOOGLE_APPLICATION_CREDENTIALS is set
      if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        console.log('🔑 Using service account file for Firebase Admin');
        app = initializeApp({
          credential: applicationDefault(),
          projectId: process.env.FIREBASE_PROJECT_ID || 'blood-sea-57816',
        });
      } else {
        // Fallback to environment variables
        console.log('🔑 Using environment variables for Firebase Admin');
        const firebaseAdminConfig = {
          projectId: process.env.FIREBASE_PROJECT_ID || 'blood-sea-57816',
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        };
        
        app = initializeApp({
          credential: cert(firebaseAdminConfig),
          projectId: firebaseAdminConfig.projectId,
        });
      }
      
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
