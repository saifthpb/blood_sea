const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin SDK
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL
};

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: process.env.FIREBASE_PROJECT_ID
  });
}

async function generateTestToken() {
  try {
    // Create a custom token for testing
    const customToken = await admin.auth().createCustomToken('test-user-123', {
      role: 'tester',
      permissions: ['send_notifications']
    });
    
    console.log('Custom Token (for Firebase sign-in):');
    console.log(customToken);
    console.log('\n');
    
    // For API testing, we'll use a simple test approach
    console.log('For API testing, use this Authorization header:');
    console.log(`Authorization: Bearer ${customToken}`);
    
  } catch (error) {
    console.error('Error generating token:', error);
  }
}

generateTestToken();
