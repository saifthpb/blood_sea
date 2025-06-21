# FCM Push Notifications Setup Guide

## Overview
Your blood_sea app now has both **database notifications** and **push notifications** implemented. When sending a blood request to a donor, the system will:

1. Save notification to Firestore database (persistent)
2. Send real-time push notification to donor's device

## Files Created/Modified

### New Files:
- `lib/services/fcm_service.dart` - FCM initialization and handling
- `lib/services/notification_service.dart` - Combined database + push notifications
- `lib/examples/notification_usage_example.dart` - Usage examples

### Modified Files:
- `lib/main.dart` - Added FCM initialization
- `pubspec.yaml` - Added http dependency

## Setup Steps

### 1. Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** > **Cloud Messaging**
4. Copy your **Server Key** (needed for sending notifications)

### 2. Update FCM Service
In `lib/services/fcm_service.dart`, replace:
```dart
'Authorization': 'key=YOUR_SERVER_KEY', // Replace with your server key
```
With your actual Firebase server key.

### 3. Implement User Authentication Integration
Update the `getCurrentUserId()` function in `fcm_service.dart`:
```dart
static String? getCurrentUserId() {
  // Replace with your auth implementation
  return FirebaseAuth.instance.currentUser?.uid;
}
```

### 4. Android Setup (if targeting Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
```

### 5. iOS Setup (if targeting iOS)
Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Usage Examples

### Send Blood Request Notification
```dart
bool success = await NotificationService.sendBloodRequestNotification(
  donorId: 'donor_user_id',
  requestId: 'request_id',
  requesterId: 'requester_user_id',
  bloodType: 'O+',
  location: 'Dhaka Medical College Hospital',
  urgency: 'urgent',
);
```

### Get User Notifications
```dart
Stream<QuerySnapshot> notifications = NotificationService.getUserNotifications(userId);
```

### Mark Notification as Read
```dart
await NotificationService.markNotificationAsRead(notificationId);
```

## Database Structure

### Notifications Collection
```json
{
  "donorId": "user_id",
  "requestId": "request_id",
  "requesterId": "requester_id",
  "type": "blood_request",
  "title": "Blood Donation Request",
  "message": "Someone needs O+ blood in Dhaka...",
  "bloodType": "O+",
  "location": "Dhaka Medical College Hospital",
  "urgency": "urgent",
  "isRead": false,
  "isResponded": false,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Users Collection (FCM Token)
```json
{
  "fcmToken": "device_fcm_token",
  "tokenUpdatedAt": "timestamp"
}
```

## Testing

### 1. Test FCM Token Generation
Run the app and check console logs for:
```
FCM Token: [your_token]
FCM token saved to database
```

### 2. Test Notification Sending
Use the example in `notification_usage_example.dart` to test sending notifications.

### 3. Test Notification Receiving
- Send a notification
- Check if it appears in device notification tray
- Tap notification to test navigation

## Important Notes

### Security
- **Never expose your Firebase Server Key** in client-side code
- Move the HTTP notification sending to your backend server
- Use Firebase Admin SDK on your server for production

### Production Recommendations
1. **Backend Integration**: Move notification sending to your backend
2. **Error Handling**: Add comprehensive error handling
3. **Rate Limiting**: Implement rate limiting for notifications
4. **User Preferences**: Allow users to control notification settings
5. **Analytics**: Track notification delivery and engagement

### Troubleshooting

#### No FCM Token Generated
- Check Firebase project configuration
- Verify app permissions
- Check device/emulator settings

#### Notifications Not Received
- Verify FCM token is saved to database
- Check Firebase server key
- Ensure device has internet connection
- Check notification permissions

#### Background Notifications Not Working
- Verify background message handler is registered
- Check device battery optimization settings
- Test on physical device (not emulator)

## Next Steps

1. **Integrate with your existing auth system**
2. **Move notification sending to backend**
3. **Add notification preferences UI**
4. **Implement notification history screen**
5. **Add notification sound/vibration customization**

## Support
If you encounter issues, check:
- Firebase Console logs
- Flutter console output
- Device notification settings
- Network connectivity
