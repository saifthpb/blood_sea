# 🩸 Blood Sea Notification Testing Guide

## 🎯 Overview
This guide covers all methods to test the notification system we've built for your Blood Sea app.

## 🔧 Backend API Testing (✅ Working)

### 1. Start the API Server
```bash
cd notification-api
npm start
```

### 2. Test API Health
```bash
curl http://localhost:3000/health
```

### 3. Generate Authentication Token
```bash
cd notification-api
node generate-test-token.js
```

### 4. Test Notification Endpoints
```bash
# Test single notification (replace TOKEN with generated token)
curl -X POST http://localhost:3000/api/notifications/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userId": "test-user-123",
    "title": "Blood Request Alert",
    "body": "Urgent: O+ blood needed at City Hospital",
    "priority": "high"
  }'

# Test blood request notification
curl -X POST http://localhost:3000/api/notifications/blood-request \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "donorId": "donor123",
    "requesterId": "requester456",
    "bloodType": "O+",
    "hospital": "City Hospital",
    "urgency": "high"
  }'
```

### 5. Run Automated Tests
```bash
./test-api.sh
```

## 📱 Flutter App Testing

### 1. Run the Flutter App
```bash
flutter run
```

### 2. Navigate to Notification Test Screen
- The app should have a notification test screen at `/notification-test`
- Or add it to your navigation manually

### 3. Test Local Notifications
In the notification test screen:
- Tap "Test Local Notification" to test device notifications
- Check if notifications appear in your device's notification panel

### 4. Test FCM Token Generation
- The screen should display your device's FCM token
- Copy this token for API testing

### 5. Test API Integration
- Use the "Test API Notification" button
- This sends a request to your local API server
- Check both app logs and device notifications

## 🔍 Testing Scenarios

### Scenario 1: Blood Request Alert
```json
{
  "type": "blood_request",
  "title": "Urgent Blood Request",
  "body": "O+ blood needed at City Hospital",
  "data": {
    "bloodType": "O+",
    "hospital": "City Hospital",
    "priority": "high",
    "requestId": "req_123"
  }
}
```

### Scenario 2: Emergency Alert
```json
{
  "type": "emergency",
  "title": "Emergency Blood Shortage",
  "body": "Critical shortage of AB- blood in your area",
  "data": {
    "bloodType": "AB-",
    "level": "critical",
    "region": "downtown"
  }
}
```

### Scenario 3: Appointment Reminder
```json
{
  "type": "appointment",
  "title": "Donation Reminder",
  "body": "Your appointment is tomorrow at 2 PM",
  "data": {
    "appointmentId": "apt_456",
    "time": "14:00",
    "location": "Blood Bank Center"
  }
}
```

## 🛠️ Troubleshooting

### API Issues
- **Port 3000 in use**: Kill existing process with `pkill -f "node server.js"`
- **Firebase errors**: Check `.env` file has correct credentials
- **Auth errors**: Generate new token with `node generate-test-token.js`

### Flutter Issues
- **FCM not working**: Check `google-services.json` is in `android/app/`
- **Permissions**: Ensure notification permissions are granted
- **Token null**: Check Firebase initialization in `main.dart`

### Device Testing
- **No notifications**: Check device notification settings
- **Silent notifications**: Check notification channels and priority
- **Background issues**: Test with app in background/closed

## 📊 Testing Checklist

### Backend API ✅
- [x] Server starts successfully
- [x] Health endpoint responds
- [x] Authentication works
- [x] Firebase Admin SDK initialized
- [x] Notification endpoints secured

### Flutter App (To Test)
- [ ] App builds and runs
- [ ] FCM token generated
- [ ] Local notifications work
- [ ] API integration works
- [ ] Background notifications work

### End-to-End (To Test)
- [ ] Send notification from API
- [ ] Receive on Flutter app
- [ ] Notification appears on device
- [ ] Tap notification opens app
- [ ] Data payload processed correctly

## 🚀 Next Steps

1. **Run Flutter App**: Test the notification screen
2. **Get Real FCM Token**: Use device token for API testing
3. **Test Background**: Ensure notifications work when app is closed
4. **Production Setup**: Configure for production Firebase project
5. **User Management**: Integrate with your user system

## 📝 Notes

- The API server must be running for Flutter app to connect
- Use real device FCM tokens for actual notification delivery
- Test on both Android and iOS if supporting both platforms
- Consider notification channels for Android (already implemented)

## 🔗 Related Files

- API Server: `notification-api/server.js`
- Flutter Service: `lib/services/notification_service_enhanced.dart`
- Test Screen: `lib/features/notifications/screens/notification_test_screen.dart`
- Test Scripts: `test-api.sh`, `notification-api/test-notification.js`
