#!/usr/bin/env node

/**
 * Simple script to get Firebase ID token for testing
 * This creates a custom token that can be used for API testing
 */

const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin
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

try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });

  console.log('🔥 Firebase Admin initialized successfully');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin:', error.message);
  process.exit(1);
}

async function createTestToken() {
  try {
    // Create a test user ID (you can change this)
    const testUserId = 'test-user-' + Date.now();
    
    // Create custom token
    const customToken = await admin.auth().createCustomToken(testUserId, {
      // Add custom claims if needed
      testUser: true,
      createdAt: new Date().toISOString()
    });

    console.log('\n🎫 Custom Token Created:');
    console.log('─'.repeat(50));
    console.log(customToken);
    console.log('─'.repeat(50));
    
    console.log('\n📋 Usage Instructions:');
    console.log('1. Copy the token above');
    console.log('2. In your Flutter app, use this token to sign in:');
    console.log('   await FirebaseAuth.instance.signInWithCustomToken(token);');
    console.log('3. Then get the ID token:');
    console.log('   final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();');
    console.log('4. Use the ID token for API testing:');
    console.log('   export FIREBASE_TOKEN="your_id_token_here"');
    console.log('   ./test-local.sh');

    console.log('\n🧪 Quick Test Command:');
    console.log(`export FIREBASE_TOKEN="${customToken}"`);
    console.log('./test-local.sh');

    console.log('\n⚠️  Note: This is a custom token. For full testing, you need to:');
    console.log('   1. Sign in with this token in your Flutter app');
    console.log('   2. Get the resulting ID token');
    console.log('   3. Use that ID token for API calls');

  } catch (error) {
    console.error('❌ Error creating custom token:', error.message);
    process.exit(1);
  }
}

async function listExistingUsers() {
  try {
    console.log('\n👥 Existing Users:');
    console.log('─'.repeat(50));
    
    const listUsersResult = await admin.auth().listUsers(10);
    
    if (listUsersResult.users.length === 0) {
      console.log('No users found in Firebase Auth');
      return null;
    }

    listUsersResult.users.forEach((userRecord, index) => {
      console.log(`${index + 1}. UID: ${userRecord.uid}`);
      console.log(`   Email: ${userRecord.email || 'No email'}`);
      console.log(`   Created: ${userRecord.metadata.creationTime}`);
      console.log('');
    });

    return listUsersResult.users[0].uid; // Return first user ID
  } catch (error) {
    console.error('❌ Error listing users:', error.message);
    return null;
  }
}

async function createTokenForExistingUser(uid) {
  try {
    const customToken = await admin.auth().createCustomToken(uid);
    
    console.log(`\n🎫 Custom Token for User ${uid}:`);
    console.log('─'.repeat(50));
    console.log(customToken);
    console.log('─'.repeat(50));
    
    return customToken;
  } catch (error) {
    console.error('❌ Error creating token for existing user:', error.message);
    return null;
  }
}

async function main() {
  console.log('🔥 Firebase Token Generator for Blood Sea API Testing');
  console.log('═'.repeat(60));

  // Check if we should use existing user
  const useExisting = process.argv.includes('--existing');
  
  if (useExisting) {
    console.log('🔍 Looking for existing users...');
    const existingUserId = await listExistingUsers();
    
    if (existingUserId) {
      await createTokenForExistingUser(existingUserId);
    } else {
      console.log('No existing users found, creating new test token...');
      await createTestToken();
    }
  } else {
    await createTestToken();
  }

  console.log('\n✨ Done! Use the token above for API testing.');
  process.exit(0);
}

// Handle command line arguments
if (process.argv.includes('--help') || process.argv.includes('-h')) {
  console.log('🔥 Firebase Token Generator');
  console.log('');
  console.log('Usage:');
  console.log('  node get-firebase-token.js           # Create token for new test user');
  console.log('  node get-firebase-token.js --existing # Use existing user from Firebase Auth');
  console.log('  node get-firebase-token.js --help     # Show this help');
  console.log('');
  console.log('Environment variables required:');
  console.log('  FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, etc. (from .env file)');
  process.exit(0);
}

main().catch(console.error);
