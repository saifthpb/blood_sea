# 🔥 Visual Guide: Getting Firebase Credentials

## 🎯 **Quick Summary**

You need to download a **Service Account JSON file** from Firebase Console and extract 6 credentials from it.

## 📸 **Step-by-Step Visual Guide**

### **Step 1: Open Firebase Console**

1. **Go to:** https://console.firebase.google.com/
2. **Sign in** with your Google account
3. **Look for:** "blood-sea-57816" project in the project list
4. **Click on** the project name to open it

```
🖥️  Firebase Console Homepage
┌─────────────────────────────────────────┐
│ Firebase                                │
│ ┌─────────────────┐ ┌─────────────────┐ │
│ │  blood-sea-57816│ │   Other Project │ │
│ │  [Click Here]   │ │                 │ │
│ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────┘
```

### **Step 2: Navigate to Project Settings**

1. **Look for:** ⚙️ gear icon in the left sidebar (usually at the bottom)
2. **Click on:** the gear icon
3. **Select:** "Project settings" from the dropdown menu

```
🖥️  Firebase Project Dashboard
┌─────────────────────────────────────────┐
│ 📊 Project Overview                     │
│ 🔥 Authentication                       │
│ 💾 Firestore Database                   │
│ 📱 Cloud Messaging                      │
│ ...                                     │
│ ⚙️  Project Settings  ← [Click Here]    │
└─────────────────────────────────────────┘
```

### **Step 3: Go to Service Accounts Tab**

1. **You'll see tabs:** General, Users and permissions, Integrations, etc.
2. **Click on:** "Service accounts" tab
3. **Look for:** "Firebase Admin SDK" section

```
🖥️  Project Settings Page
┌─────────────────────────────────────────┐
│ General | Users | Integrations | Service accounts │
│                                    ↑              │
│                              [Click Here]         │
│                                                   │
│ Firebase Admin SDK                                │
│ ┌─────────────────────────────────────────────┐   │
│ │ Generate new private key                    │   │
│ │ [Generate new private key] ← Click This     │   │
│ └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### **Step 4: Generate and Download Key**

1. **Click:** "Generate new private key" button
2. **A dialog appears** asking for confirmation
3. **Click:** "Generate key" to confirm
4. **A JSON file downloads** automatically to your Downloads folder

```
🖥️  Confirmation Dialog
┌─────────────────────────────────────────┐
│ Generate new private key                │
│                                         │
│ This will create a new private key      │
│ pair. The private key cannot be         │
│ recovered if lost.                      │
│                                         │
│ [Cancel]  [Generate key] ← Click This   │
└─────────────────────────────────────────┘
```

### **Step 5: Locate Downloaded File**

The downloaded file will be named something like:
- `blood-sea-57816-firebase-adminsdk-xyz123.json`
- Usually in your `Downloads` folder

## 🔧 **Extract Credentials (2 Methods)**

### **Method 1: Automated Script (Recommended)**

```bash
# Navigate to your API directory
cd blood_sea/notification-api

# Run the conversion script with your downloaded JSON file
node convert-firebase-json.js ~/Downloads/blood-sea-57816-firebase-adminsdk-xyz123.json

# The script will:
# ✅ Read your JSON file
# ✅ Extract all credentials
# ✅ Update your .env file automatically
# ✅ Test the configuration
```

### **Method 2: Manual Copy-Paste**

1. **Open the JSON file** in a text editor
2. **Copy values** according to this mapping:

```json
{
  "project_id": "blood-sea-57816",           ← FIREBASE_PROJECT_ID
  "private_key_id": "abc123...",             ← FIREBASE_PRIVATE_KEY_ID  
  "private_key": "-----BEGIN PRIVATE...",    ← FIREBASE_PRIVATE_KEY
  "client_email": "firebase-adminsdk...",    ← FIREBASE_CLIENT_EMAIL
  "client_id": "123456789...",               ← FIREBASE_CLIENT_ID
  "client_x509_cert_url": "https://..."     ← FIREBASE_CLIENT_CERT_URL
}
```

3. **Update your .env file:**

```bash
# Edit the .env file
nano blood_sea/notification-api/.env

# Replace these lines:
FIREBASE_PROJECT_ID=blood-sea-57816
FIREBASE_PRIVATE_KEY_ID=your_actual_key_id_here
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour_actual_key_content\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xyz@blood-sea-57816.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_actual_client_id_here
FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xyz%40blood-sea-57816.iam.gserviceaccount.com
```

## ✅ **Verify Your Setup**

### **Test 1: Check Environment Variables**
```bash
cd blood_sea/notification-api

# Check if all variables are loaded
node -e "
require('dotenv').config();
console.log('Project ID:', process.env.FIREBASE_PROJECT_ID);
console.log('Client Email:', process.env.FIREBASE_CLIENT_EMAIL);
console.log('Private Key starts with:', process.env.FIREBASE_PRIVATE_KEY?.substring(0, 30) + '...');
"
```

### **Test 2: Start the API Server**
```bash
npm run dev

# You should see:
# ✅ Firebase Admin SDK initialized successfully
# 🚀 Blood Sea Notification API server running on port 3000
```

### **Test 3: Health Check**
```bash
curl http://localhost:3000/health

# Expected response:
# {"status":"OK","timestamp":"...","uptime":123,"environment":"development"}
```

## 🚨 **Troubleshooting**

### **Problem: "File not found" when downloading**
**Solution:** 
- Check your Downloads folder
- Look for files starting with "blood-sea-57816"
- The file might have a different name

### **Problem: "Permission denied" in Firebase Console**
**Solution:**
- Make sure you're signed in with the correct Google account
- Ask the project owner to add you as a collaborator
- You need "Editor" or "Owner" role

### **Problem: "Invalid private key" error**
**Solution:**
- Use the automated script instead of manual copy-paste
- Ensure the private key has proper `\n` line breaks
- Check that quotes are properly escaped

### **Problem: Can't access blood-sea-57816 project**
**Solutions:**
1. **Ask for access:** Contact the project owner to add you
2. **Create new project:** 
   - Go to Firebase Console
   - Click "Add project"
   - Follow the setup wizard
   - Update your Flutter app configuration

## 📞 **Need Help?**

### **If you can't access the Firebase project:**
1. Contact the project owner/admin
2. Ask them to add your Google account as a collaborator
3. Or ask them to generate and securely share the service account key

### **If you're the project owner but forgot:**
1. Go to Firebase Console
2. Check if you can see the project
3. If not, check if you're signed in with the correct Google account
4. Try accessing: https://console.firebase.google.com/project/blood-sea-57816

### **Alternative: Create Your Own Project**
If you can't access the existing project:

1. **Create new Firebase project:**
   - Go to https://console.firebase.google.com/
   - Click "Add project"
   - Name it (e.g., "blood-sea-test")
   - Enable Google Analytics (optional)

2. **Update Flutter app:**
   - Run `flutterfire configure` in your Flutter project
   - Select your new project
   - This updates `firebase_options.dart`

3. **Enable required services:**
   - Authentication
   - Firestore Database
   - Cloud Messaging

---

## 🎉 **Success!**

Once you have the credentials configured:
- ✅ Your API server can send push notifications
- ✅ Firebase Admin SDK is properly initialized  
- ✅ You can test the notification system locally
- ✅ Ready for production deployment

**The automated script makes this process much easier - just run it with your downloaded JSON file!** 🚀
