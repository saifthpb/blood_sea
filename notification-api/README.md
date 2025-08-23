# Blood Sea Notification API

A robust Node.js/Express API server for handling push notifications in the Blood Sea blood donation app.

## 🚀 Features

### Core Notification Features
- **Firebase Cloud Messaging (FCM)** integration
- **Multi-platform support** (Android, iOS, Web)
- **Priority-based notifications** (Low, Normal, High, Critical)
- **Bulk notifications** for mass messaging
- **Area-based notifications** for location-specific alerts
- **Real-time notification tracking**

### Blood Donation Specific Features
- **Blood request notifications** with urgency levels
- **Emergency blood request alerts**
- **Donor availability management**
- **Location-based donor matching**
- **Automated reminder notifications**

### Advanced Features
- **Rate limiting** to prevent spam
- **Token management** with automatic cleanup
- **Notification preferences** per user
- **Comprehensive logging** and monitoring
- **Error handling** with detailed responses
- **Authentication** via Firebase ID tokens

## 📋 Prerequisites

- Node.js 16+ 
- Firebase project with Admin SDK
- Firebase Cloud Messaging enabled
- Blood Sea Flutter app configured

## 🛠️ Installation

1. **Clone and navigate to the API directory:**
```bash
cd blood_sea/notification-api
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment variables:**
```bash
cp .env.example .env
# Edit .env with your Firebase credentials
```

4. **Set up Firebase Admin SDK:**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Generate new private key
   - Add credentials to `.env` file

## ⚙️ Configuration

### Environment Variables

```bash
# Server
NODE_ENV=production
PORT=3000

# Firebase Admin SDK
FIREBASE_PROJECT_ID=blood-sea-57816
FIREBASE_PRIVATE_KEY_ID=your_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@blood-sea-57816.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id
FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...

# Security
ALLOWED_ORIGINS=https://your-app-domain.com
LOG_LEVEL=info
```

### Firebase Setup

1. **Enable Cloud Messaging:**
   - Firebase Console → Cloud Messaging
   - Note down Server Key (for legacy HTTP API if needed)

2. **Set up Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Notifications - users can read their own
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
        request.auth.uid == resource.data.recipientId;
      allow write: if request.auth != null;
    }
    
    // Blood requests
    match /blood_requests/{requestId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.donorId || 
         request.auth.uid == resource.data.requesterId);
    }
  }
}
```

## 🚀 Deployment

### Local Development
```bash
npm run dev
```

### Production Deployment

#### Option 1: Traditional Server (Ubuntu/CentOS)
```bash
# Install PM2 for process management
npm install -g pm2

# Start the application
pm2 start server.js --name "blood-sea-api"

# Set up PM2 to start on boot
pm2 startup
pm2 save
```

#### Option 2: Docker Deployment
```dockerfile
# Create Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000

USER node
CMD ["node", "server.js"]
```

```bash
# Build and run
docker build -t blood-sea-api .
docker run -p 3000:3000 --env-file .env blood-sea-api
```

#### Option 3: Cloud Deployment (Google Cloud Run)
```bash
# Build for Cloud Run
gcloud builds submit --tag gcr.io/blood-sea-57816/notification-api

# Deploy to Cloud Run
gcloud run deploy notification-api \
  --image gcr.io/blood-sea-57816/notification-api \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production
```

### Nginx Configuration (if using reverse proxy)
```nginx
server {
    listen 80;
    server_name api.bloodsea.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📡 API Endpoints

### Authentication
All endpoints require Firebase ID token in Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

### Core Endpoints

#### Send Notification
```http
POST /api/notifications/send
Content-Type: application/json

{
  "userId": "user123",
  "title": "Blood Request",
  "body": "Someone needs your blood type",
  "data": {
    "type": "bloodRequest",
    "requestId": "req123"
  },
  "priority": "high"
}
```

#### Send Blood Request
```http
POST /api/notifications/blood-request
Content-Type: application/json

{
  "donorId": "donor123",
  "requesterId": "requester456",
  "requesterName": "John Doe",
  "requesterPhone": "+1234567890",
  "bloodType": "A+",
  "location": "City Hospital, Downtown",
  "urgency": "emergency",
  "requiredDate": "2024-01-15T10:00:00Z",
  "additionalMessage": "Urgent surgery needed"
}
```

#### Bulk Notifications
```http
POST /api/notifications/bulk-send
Content-Type: application/json

{
  "userIds": ["user1", "user2", "user3"],
  "title": "Blood Drive Event",
  "body": "Join our blood donation camp tomorrow",
  "priority": "normal"
}
```

#### User Management
```http
# Update FCM Token
POST /api/users/fcm-token
{
  "fcmToken": "fcm_token_here",
  "platform": "android"
}

# Get Notifications
GET /api/notifications/user/user123?limit=20&unreadOnly=true

# Update Notification Settings
PUT /api/users/notification-settings
{
  "bloodRequests": true,
  "emergencyRequests": true,
  "soundEnabled": false
}
```

## 🔧 Flutter Integration

### Update Flutter App

1. **Update the enhanced notification service:**
```dart
// Replace the API base URL in enhanced_notification_service.dart
static const String _apiBaseUrl = 'https://your-api-domain.com/api';
```

2. **Update main.dart to use enhanced service:**
```dart
import 'package:blood_sea/services/enhanced_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Use enhanced notification service
  await EnhancedNotificationService.initialize();
  
  runApp(const MyApp());
}
```

3. **Update blood request sending:**
```dart
// In donor search screen
await EnhancedNotificationService.sendBloodRequestNotification(
  donorId: donor.uid,
  requesterId: currentUser.uid,
  requesterName: currentUser.name,
  requesterPhone: currentUser.phoneNumber,
  bloodType: bloodType,
  location: location,
  urgency: urgency,
  requiredDate: DateTime.now().add(Duration(days: 1)),
  additionalMessage: message,
);
```

## 📊 Monitoring & Logging

### Log Files
- `logs/combined.log` - All application logs
- `logs/error.log` - Error logs only
- `logs/notifications.log` - Notification-specific logs

### Health Check
```http
GET /health
```

Response:
```json
{
  "status": "OK",
  "timestamp": "2024-01-15T10:00:00Z",
  "uptime": 3600,
  "environment": "production"
}
```

### Performance Monitoring
The API includes built-in performance logging and can integrate with:
- **Sentry** for error tracking
- **New Relic** for APM
- **Prometheus** for metrics

## 🔒 Security Features

- **Rate limiting** (100 requests/15min, 10 notifications/min)
- **Firebase Authentication** validation
- **Input validation** with express-validator
- **CORS protection**
- **Helmet.js** security headers
- **Request logging** for audit trails

## 🧪 Testing

```bash
# Run tests
npm test

# Test notification endpoint
curl -X POST http://localhost:3000/api/users/test-notification \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json"
```

## 📈 Performance Optimization

### Recommended Settings
- **PM2 Cluster Mode:** Run multiple instances
- **Redis Caching:** Cache FCM tokens and user data
- **Database Indexing:** Index notification queries
- **CDN:** Use CDN for static assets

### Scaling Considerations
- **Horizontal Scaling:** Deploy multiple instances behind load balancer
- **Database Optimization:** Use Firestore composite indexes
- **Caching Strategy:** Implement Redis for frequently accessed data
- **Queue System:** Use Bull Queue for background jobs

## 🆘 Troubleshooting

### Common Issues

1. **FCM Token Invalid:**
   - Check Firebase project configuration
   - Verify service account permissions
   - Ensure tokens are being updated properly

2. **Authentication Errors:**
   - Verify Firebase ID token is valid
   - Check token expiration
   - Ensure proper Authorization header format

3. **Rate Limiting:**
   - Implement exponential backoff
   - Check rate limit headers in response
   - Consider upgrading limits for production

4. **Notification Not Received:**
   - Check device token validity
   - Verify notification permissions
   - Check Firebase Console for delivery status

### Debug Mode
Set `LOG_LEVEL=debug` in environment variables for detailed logging.

## 📞 Support

For issues and questions:
- Check logs in `/logs` directory
- Review Firebase Console for FCM delivery status
- Monitor API health endpoint
- Check Firestore security rules

---

**Note:** This API is specifically designed for the Blood Sea blood donation app and includes specialized features for blood request notifications and donor management.
