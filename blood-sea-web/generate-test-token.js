#!/usr/bin/env node

/**
 * Generate Test Firebase ID Token
 * This script creates a custom token and then exchanges it for an ID token for testing
 */

const admin = require('firebase-admin');
const { getAuth } = require('firebase-admin/auth');
const https = require('https');
const querystring = require('querystring');

// Initialize Firebase Admin SDK
try {
  const serviceAccount = require('../blood-sea-57816-firebase-adminsdk-u37i4-147b111fd6.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: 'blood-sea-57816'
  });
  
  console.log('✅ Firebase Admin SDK initialized');
} catch (error) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
  process.exit(1);
}

const auth = getAuth();

async function createTestUser() {
  const testUserData = {
    uid: 'test-user-' + Date.now(),
    email: 'test@bloodsea.com',
    emailVerified: true,
    disabled: false,
    customClaims: {
      role: 'donor',
      isDonor: true
    }
  };

  try {
    // Create user
    const userRecord = await auth.createUser(testUserData);
    console.log('✅ Test user created:', userRecord.uid);
    
    // Set custom claims
    await auth.setCustomUserClaims(userRecord.uid, testUserData.customClaims);
    console.log('✅ Custom claims set');
    
    return userRecord;
  } catch (error) {
    console.error('❌ Error creating test user:', error.message);
    throw error;
  }
}

async function generateCustomToken(uid) {
  try {
    const customToken = await auth.createCustomToken(uid, {
      role: 'donor',
      isDonor: true
    });
    console.log('✅ Custom token generated');
    return customToken;
  } catch (error) {
    console.error('❌ Error generating custom token:', error.message);
    throw error;
  }
}

function exchangeCustomTokenForIdToken(customToken, apiKey) {
  return new Promise((resolve, reject) => {
    const postData = querystring.stringify({
      token: customToken,
      returnSecureToken: true
    });

    const options = {
      hostname: 'identitytoolkit.googleapis.com',
      port: 443,
      path: `/v1/accounts:signInWithCustomToken?key=${apiKey}`,
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.idToken) {
            resolve(response.idToken);
          } else {
            reject(new Error('No ID token in response: ' + data));
          }
        } catch (error) {
          reject(new Error('Invalid JSON response: ' + data));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

async function main() {
  console.log('🔑 Generating Test Firebase ID Token');
  console.log('=====================================\n');

  try {
    // Create test user
    const userRecord = await createTestUser();
    
    // Generate custom token
    const customToken = await generateCustomToken(userRecord.uid);
    
    // You need to provide your Firebase Web API Key for this step
    const apiKey = process.env.FIREBASE_WEB_API_KEY;
    
    if (!apiKey) {
      console.log('⚠️ FIREBASE_WEB_API_KEY environment variable not set');
      console.log('You can find your Web API Key in Firebase Console > Project Settings > General');
      console.log('\nAlternatively, you can use the custom token directly for testing:');
      console.log('\n📋 Custom Token (for server-side testing):');
      console.log(customToken);
      console.log('\n📝 Test User Info:');
      console.log(`   UID: ${userRecord.uid}`);
      console.log(`   Email: ${userRecord.email}`);
      console.log('   Role: donor');
      console.log('   isDonor: true');
      
      console.log('\n🧪 You can use this token to test authenticated endpoints:');
      console.log(`curl -X GET http://localhost:3000/api/users/profile/ \\`);
      console.log(`  -H 'Content-Type: application/json' \\`);
      console.log(`  -H 'Authorization: Bearer ${customToken}'`);
      
      return;
    }
    
    // Exchange for ID token
    console.log('🔄 Exchanging custom token for ID token...');
    const idToken = await exchangeCustomTokenForIdToken(customToken, apiKey);
    
    console.log('✅ ID Token generated successfully!');
    console.log('\n📋 ID Token:');
    console.log(idToken);
    console.log('\n📝 Test User Info:');
    console.log(`   UID: ${userRecord.uid}`);
    console.log(`   Email: ${userRecord.email}`);
    console.log('   Role: donor');
    console.log('   isDonor: true');
    
    console.log('\n🧪 You can now test authenticated endpoints:');
    console.log(`curl -X GET http://localhost:3000/api/users/profile/ \\`);
    console.log(`  -H 'Content-Type: application/json' \\`);
    console.log(`  -H 'Authorization: Bearer ${idToken}'`);
    
    // Save token to file for easy access
    require('fs').writeFileSync('test-token.txt', idToken);
    console.log('\n💾 Token saved to test-token.txt');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
