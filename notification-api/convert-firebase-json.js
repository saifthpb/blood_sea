#!/usr/bin/env node

/**
 * Convert Firebase Service Account JSON to .env format
 * Usage: node convert-firebase-json.js path/to/service-account.json
 */

const fs = require('fs');
const path = require('path');

// Colors for output
const colors = {
  red: '\033[0;31m',
  green: '\033[0;32m',
  yellow: '\033[1;33m',
  blue: '\033[0;34m',
  purple: '\033[0;35m',
  cyan: '\033[0;36m',
  reset: '\033[0m'
};

function log(color, message) {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function showUsage() {
  log('blue', '🔥 Firebase JSON to .env Converter');
  console.log('');
  log('yellow', 'Usage:');
  console.log('  node convert-firebase-json.js <path-to-json-file>');
  console.log('');
  log('yellow', 'Example:');
  console.log('  node convert-firebase-json.js ~/Downloads/blood-sea-57816-firebase-adminsdk-xyz.json');
  console.log('');
  log('yellow', 'What it does:');
  console.log('  • Reads your Firebase service account JSON file');
  console.log('  • Converts it to .env format');
  console.log('  • Updates your .env file automatically');
  console.log('  • Validates the configuration');
  console.log('');
}

function validateJsonStructure(data) {
  const requiredFields = [
    'project_id',
    'private_key_id', 
    'private_key',
    'client_email',
    'client_id',
    'client_x509_cert_url'
  ];

  const missing = requiredFields.filter(field => !data[field]);
  
  if (missing.length > 0) {
    log('red', `❌ Missing required fields: ${missing.join(', ')}`);
    return false;
  }

  // Validate private key format
  if (!data.private_key.includes('-----BEGIN PRIVATE KEY-----')) {
    log('red', '❌ Invalid private key format');
    return false;
  }

  // Validate email format
  if (!data.client_email.includes('@') || !data.client_email.includes('.iam.gserviceaccount.com')) {
    log('red', '❌ Invalid client email format');
    return false;
  }

  return true;
}

function formatPrivateKey(privateKey) {
  // Ensure proper line breaks for .env format
  return privateKey.replace(/\n/g, '\\n');
}

function generateEnvContent(data) {
  const envContent = `# Firebase Configuration (Generated from service account JSON)
FIREBASE_PROJECT_ID=${data.project_id}
FIREBASE_PRIVATE_KEY_ID=${data.private_key_id}
FIREBASE_PRIVATE_KEY="${formatPrivateKey(data.private_key)}"
FIREBASE_CLIENT_EMAIL=${data.client_email}
FIREBASE_CLIENT_ID=${data.client_id}
FIREBASE_CLIENT_CERT_URL=${data.client_x509_cert_url}

# Other configuration (keep existing values)
NODE_ENV=development
PORT=3000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080,http://127.0.0.1:3000,http://10.0.2.2:3000
LOG_LEVEL=debug
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=1000
NOTIFICATION_RATE_LIMIT_WINDOW_MS=60000
NOTIFICATION_RATE_LIMIT_MAX_REQUESTS=100
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_ANALYTICS=false
`;

  return envContent;
}

function updateEnvFile(newContent) {
  const envPath = '.env';
  
  // Backup existing .env if it exists
  if (fs.existsSync(envPath)) {
    const backupPath = `.env.backup.${Date.now()}`;
    fs.copyFileSync(envPath, backupPath);
    log('yellow', `📋 Backed up existing .env to ${backupPath}`);
  }

  // Write new content
  fs.writeFileSync(envPath, newContent);
  log('green', '✅ Updated .env file with Firebase credentials');
}

function testConfiguration() {
  log('blue', '🧪 Testing Firebase configuration...');
  
  try {
    // Load environment variables
    require('dotenv').config();
    
    const requiredVars = [
      'FIREBASE_PROJECT_ID',
      'FIREBASE_PRIVATE_KEY_ID', 
      'FIREBASE_PRIVATE_KEY',
      'FIREBASE_CLIENT_EMAIL',
      'FIREBASE_CLIENT_ID',
      'FIREBASE_CLIENT_CERT_URL'
    ];

    let allSet = true;
    requiredVars.forEach(varName => {
      if (process.env[varName]) {
        log('green', `✅ ${varName} is set`);
      } else {
        log('red', `❌ ${varName} is missing`);
        allSet = false;
      }
    });

    if (allSet) {
      log('green', '🎉 All Firebase credentials are configured correctly!');
      
      // Try to initialize Firebase Admin (basic test)
      try {
        const admin = require('firebase-admin');
        
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

        // Only initialize if not already initialized
        if (admin.apps.length === 0) {
          admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
          });
        }

        log('green', '🔥 Firebase Admin SDK initialized successfully!');
        log('blue', '🚀 You can now start the API server with: npm run dev');
        
      } catch (firebaseError) {
        log('yellow', '⚠️  Environment variables are set, but Firebase initialization failed:');
        log('red', firebaseError.message);
        log('blue', '💡 This might be due to network issues or invalid credentials');
      }
    } else {
      log('red', '❌ Some Firebase credentials are missing');
    }

  } catch (error) {
    log('red', `❌ Error testing configuration: ${error.message}`);
  }
}

function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    showUsage();
    return;
  }

  const jsonFilePath = args[0];

  // Check if file exists
  if (!fs.existsSync(jsonFilePath)) {
    log('red', `❌ File not found: ${jsonFilePath}`);
    log('blue', '💡 Make sure you downloaded the service account JSON from Firebase Console');
    return;
  }

  log('blue', `📖 Reading Firebase JSON file: ${jsonFilePath}`);

  try {
    // Read and parse JSON file
    const jsonContent = fs.readFileSync(jsonFilePath, 'utf8');
    const data = JSON.parse(jsonContent);

    log('green', '✅ JSON file parsed successfully');

    // Validate structure
    if (!validateJsonStructure(data)) {
      log('red', '❌ Invalid Firebase service account JSON structure');
      log('blue', '💡 Make sure you downloaded the correct file from Firebase Console > Project Settings > Service Accounts');
      return;
    }

    log('green', '✅ JSON structure is valid');

    // Show what we found
    log('cyan', '📋 Found Firebase credentials:');
    console.log(`   Project ID: ${data.project_id}`);
    console.log(`   Client Email: ${data.client_email}`);
    console.log(`   Private Key ID: ${data.private_key_id.substring(0, 8)}...`);

    // Generate .env content
    const envContent = generateEnvContent(data);

    // Update .env file
    updateEnvFile(envContent);

    // Test configuration
    testConfiguration();

    log('green', '🎉 Firebase credentials successfully configured!');
    log('blue', '📋 Next steps:');
    console.log('   1. Start the API server: npm run dev');
    console.log('   2. Test the API: ./test-local.sh');
    console.log('   3. Update your Flutter app to use the enhanced notification service');

  } catch (error) {
    if (error instanceof SyntaxError) {
      log('red', '❌ Invalid JSON file format');
      log('blue', '💡 Make sure the file is a valid JSON file from Firebase Console');
    } else {
      log('red', `❌ Error processing file: ${error.message}`);
    }
  }
}

// Run the script
main();
