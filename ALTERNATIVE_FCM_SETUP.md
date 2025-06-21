# Alternative FCM Setup (No Server Key Required)

Since Firebase has deprecated legacy server keys for newer projects, here are modern alternatives:

## Option 1: Firebase Cloud Functions (Recommended)

### Step 1: Create a Cloud Function
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;
    
    // Get user's FCM token from Firestore
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data().fcmToken;
    
    if (!fcmToken) {
      return res.status(400).json({ error: 'User FCM token not found' });
    }
    
    // Send notification
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: data || {},
      token: fcmToken,
    };
    
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    
    res.status(200).json({ success: true, messageId: response });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: error.message });
  }
});
```

### Step 2: Deploy Cloud Function
```bash
firebase deploy --only functions
```

### Step 3: Update Your Flutter Code
```dart
// Use the new FCMServiceV2 instead of FCMService
await FCMServiceV2.sendNotificationViaCloudFunction(
  userId: donorId,
  title: 'Blood Donation Request',
  body: 'Someone needs your blood...',
  data: {'type': 'blood_request', 'requestId': requestId},
);
```

## Option 2: Backend API with Firebase Admin SDK

### Create a backend service (Node.js example):
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendNotification(userId, title, body, data) {
  try {
    // Get user's FCM token
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data().fcmToken;
    
    // Send notification
    const message = {
      notification: { title, body },
      data: data || {},
      token: fcmToken,
    };
    
    const response = await admin.messaging().send(message);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error:', error);
    return { success: false, error: error.message };
  }
}
```

## Option 3: Try Google Cloud Console for Legacy Key

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Go to **APIs & Services** > **Credentials**
4. Look for **API Keys** section
5. Find a key with "Firebase" or "FCM" in the name

## Option 4: Temporary Workaround (Client-side only)

For development/testing only, you can use Firebase's REST API v1:

```dart
// This requires OAuth 2.0 token instead of server key
static Future<String> getAccessToken() async {
  // Implementation to get OAuth 2.0 access token
  // This is complex and should be done on backend
}

static Future<bool> sendNotificationV1({
  required String token,
  required String title,
  required String body,
  Map<String, dynamic>? data,
}) async {
  final accessToken = await getAccessToken();
  
  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
      }
    }),
  );
  
  return response.statusCode == 200;
}
```

## Recommendation

**Use Option 1 (Firebase Cloud Functions)** - it's the most straightforward and secure approach for your blood_sea app.

The client-side HTTP approach with server keys is being phased out by Firebase in favor of server-side implementations.
