# 🔥 How to Get Firebase Credentials for Blood Sea API

## 📋 **What You Need**

You need these 6 Firebase credentials for the notification API:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`
- `FIREBASE_CLIENT_ID`
- `FIREBASE_CLIENT_CERT_URL`

## 🎯 **Step-by-Step Guide**

### **Step 1: Access Firebase Console**

1. **Go to Firebase Console:**
   - Open: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Select Your Project:**
   - Click on "blood-sea-57816" project
   - If you don't see it, make sure you have access to the project

### **Step 2: Navigate to Service Accounts**

1. **Go to Project Settings:**
   - Click the ⚙️ gear icon (Settings) in the left sidebar
   - Select "Project settings"

2. **Open Service Accounts Tab:**
   - Click on the "Service accounts" tab
   - You should see "Firebase Admin SDK" section

### **Step 3: Generate Service Account Key**

1. **Generate New Private Key:**
   - In the "Firebase Admin SDK" section
   - Click "Generate new private key" button
   - A dialog will appear asking for confirmation

2. **Download the JSON File:**
   - Click "Generate key" in the confirmation dialog
   - A JSON file will be downloaded to your computer
   - **Keep this file secure!** It contains sensitive credentials

### **Step 4: Extract Credentials from JSON**

The downloaded JSON file looks like this:

```json
{
  "type": "service_account",
  "project_id": "blood-sea-57816",
  "private_key_id": "abc123def456...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xyz@blood-sea-57816.iam.gserviceaccount.com",
  "client_id": "123456789012345678901",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40blood-sea-57816.iam.gserviceaccount.com"
}
```

### **Step 5: Map JSON Values to Environment Variables**

| Environment Variable | JSON Field | Example Value |
|---------------------|------------|---------------|
| `FIREBASE_PROJECT_ID` | `project_id` | `blood-sea-57816` |
| `FIREBASE_PRIVATE_KEY_ID` | `private_key_id` | `abc123def456...` |
| `FIREBASE_PRIVATE_KEY` | `private_key` | `-----BEGIN PRIVATE KEY-----\n...` |
| `FIREBASE_CLIENT_EMAIL` | `client_email` | `firebase-adminsdk-xyz@blood-sea-57816.iam.gserviceaccount.com` |
| `FIREBASE_CLIENT_ID` | `client_id` | `123456789012345678901` |
| `FIREBASE_CLIENT_CERT_URL` | `client_x509_cert_url` | `https://www.googleapis.com/robot/v1/metadata/x509/...` |

## 🔧 **Update Your .env File**

### **Method 1: Manual Copy-Paste**

1. **Open your .env file:**
   ```bash
   cd blood_sea/notification-api
   nano .env
   ```

2. **Replace the placeholder values:**
   ```bash
   FIREBASE_PROJECT_ID=blood-sea-57816
   FIREBASE_PRIVATE_KEY_ID=your_actual_private_key_id_here
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour_actual_private_key_content_here\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xyz@blood-sea-57816.iam.gserviceaccount.com
   FIREBASE_CLIENT_ID=your_actual_client_id_here
   FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40blood-sea-57816.iam.gserviceaccount.com
   ```

### **Method 2: Automated Script**

I'll create a script to help you convert the JSON file:

```bash
# Use the conversion script (created below)
node convert-firebase-json.js path/to/your/downloaded-file.json
```

## ⚠️ **Important Notes**

### **Private Key Formatting**
The private key must be properly formatted with `\n` for line breaks:

**❌ Wrong:**
```
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
-----END PRIVATE KEY-----
```

**✅ Correct:**
```
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
```

### **Security Best Practices**
- ✅ Never commit the .env file to version control
- ✅ Keep the JSON file secure and don't share it
- ✅ Add .env to your .gitignore file
- ✅ Use different service accounts for development and production

## 🧪 **Test Your Configuration**

After updating the .env file, test if it works:

```bash
cd notification-api

# Test Firebase connection
node -e "
require('dotenv').config();
console.log('Project ID:', process.env.FIREBASE_PROJECT_ID);
console.log('Client Email:', process.env.FIREBASE_CLIENT_EMAIL);
console.log('Private Key ID:', process.env.FIREBASE_PRIVATE_KEY_ID);
"

# Start the server
npm run dev
```

If configured correctly, you should see:
```
✅ Firebase Admin SDK initialized successfully
🚀 Blood Sea Notification API server running on port 3000
```

## 🚨 **Troubleshooting**

### **Common Issues:**

1. **"Invalid private key" error:**
   - Check that the private key has proper `\n` line breaks
   - Ensure the key is wrapped in quotes
   - Verify the key starts with `-----BEGIN PRIVATE KEY-----`

2. **"Project not found" error:**
   - Verify the project ID is correct
   - Check that you have access to the Firebase project

3. **"Permission denied" error:**
   - Ensure the service account has proper permissions
   - Try generating a new service account key

4. **"Invalid client email" error:**
   - Check that the client email matches the downloaded JSON
   - Verify there are no extra spaces or characters

### **Validation Commands:**

```bash
# Check if all variables are set
cd notification-api
node -e "
require('dotenv').config();
const required = ['FIREBASE_PROJECT_ID', 'FIREBASE_PRIVATE_KEY_ID', 'FIREBASE_PRIVATE_KEY', 'FIREBASE_CLIENT_EMAIL', 'FIREBASE_CLIENT_ID', 'FIREBASE_CLIENT_CERT_URL'];
required.forEach(key => {
  if (process.env[key]) {
    console.log('✅', key, 'is set');
  } else {
    console.log('❌', key, 'is missing');
  }
});
"
```

## 🔄 **Alternative: Using Firebase CLI**

If you have Firebase CLI installed:

```bash
# Login to Firebase
firebase login

# Get project info
firebase projects:list

# Use Firebase CLI for authentication (alternative method)
firebase use blood-sea-57816
```

## 📞 **Need Help?**

If you're still having trouble:

1. **Check Firebase Console Access:**
   - Make sure you can access: https://console.firebase.google.com/project/blood-sea-57816
   - Verify you have "Editor" or "Owner" role

2. **Contact Project Owner:**
   - If you don't have access, ask the project owner to:
     - Add you as a collaborator
     - Generate and share the service account key securely

3. **Create New Project (if needed):**
   - If you can't access the existing project
   - Create a new Firebase project
   - Update the project ID in your Flutter app configuration

---

**Once you have these credentials configured, your notification API will be able to send push notifications through Firebase Cloud Messaging!** 🚀
