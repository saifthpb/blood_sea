# 🧪 Local Testing Guide - Blood Sea Notification System

## 🚀 Quick Start (5 Minutes)

### Step 1: Set Up the API Server

```bash
# Navigate to the notification API directory
cd blood_sea/notification-api

# Run the setup script
./setup-local.sh

# This will:
# ✅ Check Node.js installation
# ✅ Install dependencies
# ✅ Create .env file
# ✅ Set up logs directory
```

### Step 2: Configure Firebase Credentials

1. **Get Firebase Service Account Key:**
   - Go to [Firebase Console](https://console.firebase.google.com/project/blood-sea-57816/settings/serviceaccounts/adminsdk)
   - Click "Generate new private key"
   - Download the JSON file

2. **Update .env file:**
```bash
# Edit the .env file with your Firebase credentials
nano .env

# Or copy from the local template
cp .env.local .env
```

3. **Add your Firebase credentials to .env:**
```bash
FIREBASE_PROJECT_ID=blood-sea-57816
FIREBASE_PRIVATE_KEY_ID=your_key_id_from_json
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour_private_key_content\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@blood-sea-57816.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...
```

### Step 3: Start the API Server

```bash
# Start in development mode (with auto-reload)
npm run dev

# Or start in production mode
npm start
```

You should see:
```
🚀 Blood Sea Notification API server running on port 3000
📱 Environment: development
🔔 Notification service ready
```

### Step 4: Test the API

```bash
# Run the test script
./test-local.sh

# This will test:
# ✅ Health endpoint
# ✅ Basic API functionality
```

## 🔧 Detailed Setup Instructions

### Prerequisites

1. **Node.js 16+**
   ```bash
   # Check version
   node --version
   
   # Install if needed (Ubuntu/Debian)
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

2. **Firebase Project Access**
   - Admin access to the blood-sea-57816 Firebase project
   - Service account key with proper permissions

### Manual Setup (Alternative to setup script)

1. **Install dependencies:**
   ```bash
   cd notification-api
   npm install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase credentials
   ```

3. **Create logs directory:**
   ```bash
   mkdir -p logs
   ```

4. **Start the server:**
   ```bash
   npm run dev
   ```

## 🧪 Testing the System

### 1. Basic Health Check

```bash
# Test if server is running
curl http://localhost:3000/health

# Expected response:
{
  "status": "OK",
  "timestamp": "2024-01-15T10:00:00Z",
  "uptime": 123,
  "environment": "development"
}
```

### 2. Get Firebase ID Token (for authenticated tests)

**Option A: From Flutter App**
```dart
// In your Flutter app, add this temporary code
final user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final token = await user.getIdToken();
  print('Firebase Token: $token');
}
```

**Option B: Using Firebase CLI**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and get token
firebase login
firebase auth:print-users --project blood-sea-57816
```

### 3. Test Authenticated Endpoints

```bash
# Set your Firebase token
export FIREBASE_TOKEN="your_firebase_id_token_here"

# Run comprehensive tests
./test-local.sh
```

### 4. Manual API Testing

**Update FCM Token:**
```bash
curl -X POST http://localhost:3000/api/users/fcm-token \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fcmToken": "test_fcm_token_123",
    "platform": "android"
  }'
```

**Send Test Notification:**
```bash
curl -X POST http://localhost:3000/api/users/test-notification \
  -H "Authorization: Bearer $FIREBASE_TOKEN"
```

**Send Blood Request:**
```bash
curl -X POST http://localhost:3000/api/notifications/blood-request \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "donorId": "donor_user_id",
    "requesterId": "requester_user_id",
    "requesterName": "John Doe",
    "requesterPhone": "+1234567890",
    "bloodType": "A+",
    "location": "City Hospital, Downtown",
    "urgency": "urgent",
    "requiredDate": "2024-01-16T10:00:00Z",
    "additionalMessage": "Urgent surgery needed"
  }'
```

## 📱 Testing with Flutter App

### 1. Update Flutter App Configuration

```dart
// In lib/services/notification_service_enhanced.dart
// Update the API base URL for local testing
static const String _apiBaseUrl = 'http://localhost:3000/api';

// For Android emulator, use:
// static const String _apiBaseUrl = 'http://10.0.2.2:3000/api';

// For iOS simulator, use:
// static const String _apiBaseUrl = 'http://127.0.0.1:3000/api';
```

### 2. Update main.dart

```dart
import 'package:blood_sea/services/notification_service_enhanced.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize enhanced notification service
  await NotificationServiceEnhanced.initialize();
  
  runApp(const MyApp());
}
```

### 3. Test Blood Request from Flutter

```dart
// In your donor search screen
final result = await NotificationServiceEnhanced.sendBloodRequestNotification(
  donorId: donor.uid,
  requesterId: currentUser.uid,
  requesterName: currentUser.name ?? 'Test User',
  requesterPhone: currentUser.phoneNumber ?? '+1234567890',
  bloodType: 'A+',
  location: 'Test Hospital, Test City',
  urgency: 'urgent',
  requiredDate: DateTime.now().add(Duration(days: 1)),
  additionalMessage: 'This is a test from Flutter app',
);

print('Blood request sent: $result');
```

## 🔍 Monitoring and Debugging

### 1. View Logs

```bash
# View all logs
tail -f logs/combined.log

# View only errors
tail -f logs/error.log

# View notification-specific logs
tail -f logs/notifications.log

# View logs with filtering
grep "ERROR" logs/combined.log
grep "blood_request" logs/notifications.log
```

### 2. Debug Mode

```bash
# Start with debug logging
LOG_LEVEL=debug npm run dev

# Or set in .env file
echo "LOG_LEVEL=debug" >> .env
```

### 3. Monitor API Performance

```bash
# Install htop for system monitoring
sudo apt install htop
htop

# Monitor API requests
curl -s http://localhost:3000/health | jq
```

## 🚨 Troubleshooting

### Common Issues and Solutions

1. **Port 3000 already in use:**
   ```bash
   # Find process using port 3000
   lsof -i :3000
   
   # Kill the process
   kill -9 <PID>
   
   # Or use different port
   PORT=3001 npm run dev
   ```

2. **Firebase authentication errors:**
   ```bash
   # Check if credentials are correct
   node -e "console.log(process.env.FIREBASE_PROJECT_ID)"
   
   # Verify service account permissions in Firebase Console
   ```

3. **Module not found errors:**
   ```bash
   # Clear npm cache and reinstall
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **CORS errors from Flutter:**
   ```bash
   # Add your Flutter app URL to ALLOWED_ORIGINS in .env
   ALLOWED_ORIGINS=http://localhost:3000,http://10.0.2.2:3000
   ```

### Debug Checklist

- [ ] Node.js 16+ installed
- [ ] Firebase credentials configured correctly
- [ ] API server running on port 3000
- [ ] Health endpoint responding
- [ ] Firebase ID token valid
- [ ] Firestore security rules allow access
- [ ] Flutter app pointing to correct API URL

## 📊 Performance Testing

### Load Testing with Artillery

```bash
# Install artillery
npm install -g artillery

# Test health endpoint
artillery quick --count 100 --num 10 http://localhost:3000/health

# Test with authentication (create test-load.yml)
artillery run test-load.yml
```

### Memory and CPU Monitoring

```bash
# Monitor Node.js process
top -p $(pgrep -f "node.*server.js")

# Monitor memory usage
ps aux | grep node
```

## 🎯 Next Steps

1. **Test basic functionality** with the provided scripts
2. **Integrate with Flutter app** using the enhanced service
3. **Test end-to-end flow** from Flutter to API to Firebase
4. **Monitor logs** for any issues
5. **Optimize performance** based on testing results

## 📞 Getting Help

If you encounter issues:

1. **Check logs** in the `logs/` directory
2. **Verify Firebase configuration** in Firebase Console
3. **Test API endpoints** individually using curl
4. **Check Flutter app configuration** for correct API URL
5. **Monitor system resources** (CPU, memory, network)

---

**Your local testing environment is now ready! 🚀**

The system provides comprehensive logging, error handling, and monitoring to help you debug any issues during development.
