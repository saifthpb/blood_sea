const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Firebase Admin SDK
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL
};

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: process.env.FIREBASE_PROJECT_ID
  });
  console.log('✅ Firebase Admin SDK initialized successfully');
}

const db = admin.firestore();
const messaging = admin.messaging();

// Middleware
app.use(helmet());
app.use(cors({
  origin: ['https://blood-sea-57816.web.app', 'http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests from this IP, please try again later.'
  }
});
app.use('/api/', limiter);

// Authentication middleware
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Authorization header missing or invalid format'
      });
    }

    const token = authHeader.substring(7);
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
      error: error.code
    });
  }
};

// Helper function to get compatible blood types
const getCompatibleBloodTypes = (requestedType) => {
  const compatibility = {
    'O-': ['O-'],
    'O+': ['O-', 'O+'],
    'A-': ['O-', 'A-'],
    'A+': ['O-', 'O+', 'A-', 'A+'],
    'B-': ['O-', 'B-'],
    'B+': ['O-', 'O+', 'B-', 'B+'],
    'AB-': ['O-', 'A-', 'B-', 'AB-'],
    'AB+': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
  };
  return compatibility[requestedType] || [requestedType];
};

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'blood-sea-notification-api',
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// API info
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Blood Sea Notification API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      sendNotification: 'POST /api/notifications/send',
      bloodRequest: 'POST /api/notifications/blood-request',
      bulkNotification: 'POST /api/notifications/bulk'
    },
    authentication: 'Bearer token required',
    documentation: 'https://blood-sea-57816.web.app/api'
  });
});

// Send single notification
app.post('/api/notifications/send', authenticateToken, async (req, res) => {
  try {
    const { userId, fcmToken, title, body, data = {}, priority = 'normal', type = 'general' } = req.body;

    // Validate required fields
    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'Title and body are required'
      });
    }

    if (!userId && !fcmToken) {
      return res.status(400).json({
        success: false,
        message: 'Either userId or fcmToken is required'
      });
    }

    let targetToken = fcmToken;

    // Get FCM token from user document if not provided
    if (!targetToken && userId) {
      const userDoc = await db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        targetToken = userDoc.data().fcmToken;
      }
    }

    if (!targetToken) {
      return res.status(400).json({
        success: false,
        message: 'No FCM token available for user'
      });
    }

    // Create message
    const message = {
      notification: { title, body },
      data: {
        type,
        priority,
        timestamp: new Date().toISOString(),
        ...data,
      },
      token: targetToken,
      android: {
        notification: {
          channelId: type,
          priority: priority === 'high' || priority === 'critical' ? 'high' : 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: { title, body },
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    // Send notification
    const response = await messaging.send(message);

    // Log notification
    await db.collection('notifications').add({
      userId,
      title,
      body,
      type,
      priority,
      status: 'sent',
      messageId: response,
      timestamp: new Date(),
    });

    res.json({
      success: true,
      message: 'Notification sent successfully',
      messageId: response,
    });

  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
});

// Send blood request notification
app.post('/api/notifications/blood-request', authenticateToken, async (req, res) => {
  try {
    const { donorId, requesterId, bloodType, hospital, urgency, location, contactInfo } = req.body;

    // Validate required fields
    const requiredFields = ['donorId', 'requesterId', 'bloodType', 'hospital', 'urgency'];
    const missingFields = requiredFields.filter(field => !req.body[field]);

    if (missingFields.length > 0) {
      return res.status(400).json({
        success: false,
        message: `Missing required fields: ${missingFields.join(', ')}`
      });
    }

    // Get compatible blood types
    const compatibleTypes = getCompatibleBloodTypes(bloodType);

    // Find eligible donors
    const donorsQuery = await db.collection('users')
      .where('role', '==', 'donor')
      .where('bloodType', 'in', compatibleTypes)
      .where('isAvailable', '==', true)
      .get();

    const eligibleDonors = donorsQuery.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    if (eligibleDonors.length === 0) {
      return res.json({
        success: false,
        message: 'No eligible donors found',
        notifiedDonors: 0
      });
    }

    // Get FCM tokens
    const fcmTokens = eligibleDonors
      .map(donor => donor.fcmToken)
      .filter(token => token);

    if (fcmTokens.length === 0) {
      return res.json({
        success: false,
        message: 'No FCM tokens available for eligible donors',
        notifiedDonors: 0
      });
    }

    // Send notifications
    const message = {
      notification: {
        title: `Urgent: ${bloodType} Blood Needed`,
        body: `${hospital} needs ${bloodType} blood. Can you help?`,
      },
      data: {
        type: 'blood_request',
        requestId: `req_${Date.now()}`,
        bloodType,
        hospital,
        urgency,
        location: location || '',
        contactInfo: contactInfo || '',
        timestamp: new Date().toISOString(),
      },
      tokens: fcmTokens,
      android: {
        notification: {
          channelId: 'blood_request',
          priority: urgency === 'high' || urgency === 'critical' ? 'high' : 'default',
        },
      },
    };

    const response = await messaging.sendEachForMulticast(message);

    // Log blood request
    await db.collection('blood_requests').add({
      donorId,
      requesterId,
      bloodType,
      hospital,
      urgency,
      location,
      contactInfo,
      timestamp: new Date(),
      notifiedDonors: response.successCount,
      status: 'active',
    });

    res.json({
      success: response.successCount > 0,
      message: `Blood request notification sent to ${response.successCount} eligible donors`,
      notifiedDonors: response.successCount,
      failedCount: response.failureCount,
    });

  } catch (error) {
    console.error('Error sending blood request notification:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
});

// Bulk notifications
app.post('/api/notifications/bulk', authenticateToken, async (req, res) => {
  try {
    const { userIds, fcmTokens, title, body, data = {}, priority = 'normal', type = 'general' } = req.body;

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'Title and body are required'
      });
    }

    let targetTokens = fcmTokens || [];

    // Get FCM tokens from user IDs if not provided
    if (targetTokens.length === 0 && userIds && userIds.length > 0) {
      const userDocs = await db.collection('users')
        .where('__name__', 'in', userIds)
        .get();

      targetTokens = userDocs.docs
        .map(doc => doc.data().fcmToken)
        .filter(token => token);
    }

    if (targetTokens.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No FCM tokens available'
      });
    }

    const message = {
      notification: { title, body },
      data: {
        type,
        priority,
        timestamp: new Date().toISOString(),
        ...data,
      },
      tokens: targetTokens,
      android: {
        notification: {
          channelId: type,
          priority: priority === 'high' || priority === 'critical' ? 'high' : 'default',
        },
      },
    };

    const response = await messaging.sendEachForMulticast(message);

    res.json({
      success: response.successCount > 0,
      message: `Bulk notification processed: ${response.successCount} sent, ${response.failureCount} failed`,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

  } catch (error) {
    console.error('Error sending bulk notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `The requested route ${req.originalUrl} does not exist.`
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Blood Sea Notification API server running on port ${PORT}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔔 Notification service ready`);
  console.log(`🌐 Admin Panel: https://blood-sea-57816.web.app`);
});
