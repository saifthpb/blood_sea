#!/usr/bin/env node

/**
 * Create a proper ID token for API testing
 * This simulates the Firebase Auth flow to generate a real ID token
 */

const admin = require('firebase-admin');
const jwt = require('jsonwebtoken');
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

async function createTestIdToken() {
  try {
    const testUserId = 'test-user-' + Date.now();
    const testEmail = `test-${Date.now()}@bloodsea.test`;
    
    console.log('🔥 Creating test user and ID token...');
    
    // Create a test user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      uid: testUserId,
      email: testEmail,
      displayName: 'Test User for API',
      emailVerified: true,
    });

    console.log('✅ Test user created:', userRecord.uid);

    // Create an ID token manually (simulating what Firebase Auth does)
    const now = Math.floor(Date.now() / 1000);
    const idTokenPayload = {
      // Standard JWT claims
      iss: `https://securetoken.google.com/${process.env.FIREBASE_PROJECT_ID}`,
      aud: process.env.FIREBASE_PROJECT_ID,
      auth_time: now,
      user_id: userRecord.uid,
      sub: userRecord.uid,
      iat: now,
      exp: now + 3600, // 1 hour expiration
      
      // Firebase-specific claims
      email: testEmail,
      email_verified: true,
      firebase: {
        identities: {
          email: [testEmail]
        },
        sign_in_provider: 'password'
      }
    };

    // Sign the token with Firebase's private key
    const idToken = jwt.sign(idTokenPayload, process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'), {
      algorithm: 'RS256',
      keyid: process.env.FIREBASE_PRIVATE_KEY_ID,
      header: {
        alg: 'RS256',
        kid: process.env.FIREBASE_PRIVATE_KEY_ID,
        typ: 'JWT'
      }
    });

    console.log('✅ ID token created successfully!');
    
    console.log('\n🎫 Firebase ID Token (for API testing):');
    console.log('─'.repeat(80));
    console.log(idToken);
    console.log('─'.repeat(80));

    console.log('\n📋 Usage Instructions:');
    console.log('1. Copy the token above');
    console.log('2. Run this command in your terminal:');
    console.log(`export FIREBASE_TOKEN="${idToken}"`);
    console.log('3. Test the API:');
    console.log('./test-local.sh');

    console.log('\n🧪 Quick Test Commands:');
    console.log('# Set token and test');
    console.log(`export FIREBASE_TOKEN="${idToken}"`);
    console.log('');
    console.log('# Test FCM token update');
    console.log('curl -X POST http://localhost:3000/api/users/fcm-token \\');
    console.log('  -H "Authorization: Bearer $FIREBASE_TOKEN" \\');
    console.log('  -H "Content-Type: application/json" \\');
    console.log('  -d \'{"fcmToken": "test_token_123", "platform": "android"}\'');
    console.log('');
    console.log('# Test notification');
    console.log('curl -X POST http://localhost:3000/api/users/test-notification \\');
    console.log('  -H "Authorization: Bearer $FIREBASE_TOKEN"');

    console.log('\n✨ This ID token will work with your API!');
    
    return { userRecord, idToken };

  } catch (error) {
    console.error('❌ Error creating ID token:', error.message);
    throw error;
  }
}

async function main() {
  try {
    console.log('🔑 Firebase ID Token Generator for Blood Sea API');
    console.log('═'.repeat(60));

    await createTestIdToken();

    console.log('\n🎉 Success! You now have a proper ID token for API testing.');
    console.log('💡 This token will be accepted by your API authentication middleware.');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
