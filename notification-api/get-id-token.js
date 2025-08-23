#!/usr/bin/env node

/**
 * Convert custom token to ID token for API testing
 * This simulates what happens in a Flutter app
 */

const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin if not already done
if (admin.apps.length === 0) {
  const serviceAccount = {
    type: "service_account",
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL
  };

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

async function createTestUser() {
  try {
    const testUserId = 'test-user-' + Date.now();
    
    console.log('🔥 Creating test user for API testing...');
    
    // Create a test user
    const userRecord = await admin.auth().createUser({
      uid: testUserId,
      email: `test-${Date.now()}@bloodsea.test`,
      displayName: 'Test User',
      emailVerified: true,
    });

    console.log('✅ Test user created:', userRecord.uid);

    // Create custom token for this user
    const customToken = await admin.auth().createCustomToken(userRecord.uid, {
      testUser: true,
      createdAt: new Date().toISOString()
    });

    console.log('✅ Custom token created');

    // Simulate what happens in Flutter app - exchange custom token for ID token
    // Note: This is a simplified version. In real Flutter app, you'd use Firebase Auth SDK
    
    console.log('\n🎫 Custom Token (for Flutter sign-in):');
    console.log('─'.repeat(50));
    console.log(customToken);
    console.log('─'.repeat(50));

    console.log('\n📋 To get ID token in Flutter app:');
    console.log('1. Use this custom token to sign in:');
    console.log('   await FirebaseAuth.instance.signInWithCustomToken(customToken);');
    console.log('2. Then get the ID token:');
    console.log('   final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();');
    console.log('3. Use the ID token for API testing');

    console.log('\n💡 Alternative: Use the GetTokenScreen in your Flutter app');
    console.log('   It will automatically get the ID token from your logged-in user');

    return { userRecord, customToken };

  } catch (error) {
    console.error('❌ Error creating test user:', error.message);
    throw error;
  }
}

async function main() {
  try {
    console.log('🔑 Firebase ID Token Generator for API Testing');
    console.log('═'.repeat(60));

    const { userRecord, customToken } = await createTestUser();

    console.log('\n🎯 Next Steps:');
    console.log('1. Add the GetTokenScreen to your Flutter app (see ADD_TOKEN_SCREEN.md)');
    console.log('2. Sign in to your Flutter app with any user');
    console.log('3. Use the GetTokenScreen to get your ID token');
    console.log('4. Use that ID token for API testing');

    console.log('\n🧪 For immediate testing:');
    console.log('You can use the custom token above to sign in to Firebase in your Flutter app,');
    console.log('then get the resulting ID token for API testing.');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
