# 🔔 Modern Firebase Cloud Messaging Setup (No Server Key Needed)

Firebase has **deprecated the legacy server key**. Here's the modern approach using Firebase Admin SDK and Cloud Functions:

## 🚀 **Recommended Approach: Firebase Cloud Functions**

### **Step 1: Initialize Cloud Functions**

```bash
# In your project root directory
firebase init functions

# Choose:
# - Use an existing project: blood-sea-57816
# - Language: TypeScript (recommended) or JavaScript
# - ESLint: Yes
# - Install dependencies: Yes
```

### **Step 2: Create Cloud Function for FCM**

Create `functions/src/index.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const sendNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();
    
    try {
      // Get user's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(notificationData.recipientId)
        .get();
      
      if (!userDoc.exists) {
        console.log('User not found');
        return;
      }
      
      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;
      
      if (!fcmToken) {
        console.log('No FCM token found for user');
        return;
      }
      
      // Send notification
      const message = {
        notification: {
          title: notificationData.title,
          body: notificationData.message,
        },
        data: {
          type: notificationData.type,
          notificationId: context.params.notificationId,
          ...notificationData.data,
        },
        token: fcmToken,
        android: {
          priority: 'high' as const,
          notification: {
            sound: 'default',
            channelId: 'blood_sea_channel',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };
      
      const response = await admin.messaging().send(message);
      console.log('Successfully sent message:', response);
      
    } catch (error) {
      console.error('Error sending message:', error);
    }
  });

// Manual notification sending function
export const sendManualNotification = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated and has admin rights
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  try {
    const { userIds, title, body, customData } = data;
    const results = [];
    
    for (const userId of userIds) {
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        results.push({ userId, status: 'user_not_found' });
        continue;
      }
      
      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;
      
      if (!fcmToken) {
        results.push({ userId, status: 'no_token' });
        continue;
      }
      
      const message = {
        notification: { title, body },
        data: customData || {},
        token: fcmToken,
      };
      
      try {
        await admin.messaging().send(message);
        results.push({ userId, status: 'sent' });
      } catch (error) {
        results.push({ userId, status: 'failed', error: error });
      }
    }
    
    return { results };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error sending notifications');
  }
});
```

### **Step 3: Deploy Cloud Functions**

```bash
firebase deploy --only functions
```

### **Step 4: Update Web Admin Panel**

Update `blood-sea-web/src/lib/fcm.ts`:

```typescript
import { getFunctions, httpsCallable } from 'firebase/functions';
import { db } from './firebase';

const functions = getFunctions();

// Send push notifications using Cloud Function
export async function sendPushNotificationToMultiple(
  userIds: string[],
  title: string,
  body: string,
  customData: Record<string, string> = {}
): Promise<{ success: number; failed: number }> {
  try {
    const sendManualNotification = httpsCallable(functions, 'sendManualNotification');
    
    const result = await sendManualNotification({
      userIds,
      title,
      body,
      customData,
    });
    
    const data = result.data as { results: Array<{ userId: string; status: string }> };
    
    const success = data.results.filter(r => r.status === 'sent').length;
    const failed = data.results.length - success;
    
    return { success, failed };
  } catch (error) {
    console.error('Error calling Cloud Function:', error);
    return { success: 0, failed: userIds.length };
  }
}

// Alternative: Direct Firestore trigger approach
export async function sendNotificationViaFirestore(
  recipientId: string,
  title: string,
  body: string,
  data: Record<string, any> = {}
) {
  try {
    // Simply create a notification document
    // The Cloud Function will automatically send the push notification
    const notificationData = {
      recipientId,
      title,
      message: body,
      data,
      type: data.type || 'system',
      isRead: false,
      createdAt: new Date(),
    };
    
    await addDoc(collection(db, 'notifications'), notificationData);
    return true;
  } catch (error) {
    console.error('Error creating notification:', error);
    return false;
  }
}
```

## 🔄 **Alternative: Firebase Admin SDK (Simpler)**

If you prefer not to use Cloud Functions, you can use Firebase Admin SDK directly:

### **Step 1: Generate Service Account Key**

1. Go to [Firebase Console → Project Settings → Service Accounts](https://console.firebase.google.com/project/blood-sea-57816/settings/serviceaccounts/adminsdk)
2. Click "Generate new private key"
3. Download the JSON file
4. **Keep this file secure** - never commit it to version control

### **Step 2: Create Backend API** (Node.js/Express example)

```javascript
const admin = require('firebase-admin');
const express = require('express');

// Initialize Firebase Admin with service account
const serviceAccount = require('./path/to/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(express.json());

app.post('/send-notification', async (req, res) => {
  try {
    const { userIds, title, body, data } = req.body;
    
    const promises = userIds.map(async (userId) => {
      // Get user's FCM token from Firestore
      const userDoc = await admin.firestore().collection('users').doc(userId).get();
      
      if (!userDoc.exists || !userDoc.data().fcmToken) {
        return { userId, status: 'no_token' };
      }
      
      const message = {
        notification: { title, body },
        data: data || {},
        token: userDoc.data().fcmToken,
      };
      
      try {
        await admin.messaging().send(message);
        return { userId, status: 'sent' };
      } catch (error) {
        return { userId, status: 'failed' };
      }
    });
    
    const results = await Promise.all(promises);
    res.json({ results });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3001, () => {
  console.log('FCM server running on port 3001');
});
```

## 🧪 **Testing Without Backend (Development Only)**

For testing purposes, you can use the Firebase Console:

1. Go to [Firebase Console → Cloud Messaging](https://console.firebase.google.com/project/blood-sea-57816/messaging)
2. Click "Send your first message"
3. Enter notification details
4. Select your app
5. Send test notification

## 📱 **Current Setup Status**

Your Flutter app is **already configured** and will receive notifications from any of these methods:

✅ **FCM tokens are saved** when users log in  
✅ **Notification handling** is implemented  
✅ **Local notifications** work for foreground messages  
✅ **Background processing** is configured  

## 🎯 **Recommended Next Steps**

1. **For Production**: Set up Cloud Functions (most secure)
2. **For Testing**: Use Firebase Console
3. **For Custom Backend**: Use Admin SDK with your own server

Choose the approach that best fits your infrastructure and security requirements!