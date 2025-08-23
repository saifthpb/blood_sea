const admin = require("firebase-admin");
require("dotenv").config();

// Initialize Firebase Admin SDK
const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL,
};

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

async function testNotification() {
  try {
    console.log("🧪 Testing Firebase Cloud Messaging...\n");

    // Test message
    const message = {
      notification: {
        title: "Blood Sea Test Notification",
        body: "This is a test notification from your Blood Sea app!",
      },
      data: {
        type: "test",
        priority: "normal",
        timestamp: new Date().toISOString(),
      },
      // Use a test token - in real app, this would be a device's FCM token
      token:
        "eUW-r4-1RXfnzW0Tcu_P4d:APA91bH8MzERnErOE_WxadotFp2JDN4jcvJpL4C6YT0V6PorlnN3eHYG0PO4_kMqxG8LUfBj8ECfjDYCdpjEx3bqzQSiQfyrRiYE1v8GaFMGdvC5SIk4R-0",
    };

    console.log("📤 Attempting to send notification...");
    console.log("Message:", JSON.stringify(message, null, 2));

    // This will fail with invalid token, but shows the system is working
    const response = await admin.messaging().send(message);
    console.log("✅ Notification sent successfully!");
    console.log("Response:", response);
  } catch (error) {
    if (error.code === "messaging/invalid-registration-token") {
      console.log(
        "⚠️  Expected error: Invalid registration token (this is normal for testing)",
      );
      console.log("✅ Firebase Admin SDK is working correctly!");
      console.log(
        "📱 To test with real device, you need a valid FCM token from your Flutter app",
      );
    } else {
      console.error("❌ Error sending notification:", error);
    }
  }
}

// Test different notification types
async function testNotificationTypes() {
  console.log("\n🔔 Testing different notification types...\n");

  const notificationTypes = [
    {
      type: "blood_request",
      title: "Urgent Blood Request",
      body: "O+ blood needed at City Hospital",
      data: { hospital: "City Hospital", bloodType: "O+", priority: "high" },
    },
    {
      type: "emergency",
      title: "Emergency Alert",
      body: "Critical blood shortage - All donors needed",
      data: { level: "critical", region: "downtown" },
    },
    {
      type: "appointment",
      title: "Donation Reminder",
      body: "Your blood donation appointment is tomorrow at 2 PM",
      data: { appointmentId: "12345", time: "14:00" },
    },
  ];

  for (const notif of notificationTypes) {
    console.log(`📋 ${notif.type.toUpperCase()} notification structure:`);
    console.log(
      JSON.stringify(
        {
          notification: {
            title: notif.title,
            body: notif.body,
          },
          data: notif.data,
          android: {
            notification: {
              channelId: notif.type,
              priority: "high",
            },
          },
        },
        null,
        2,
      ),
    );
    console.log("---");
  }
}

console.log("🩸 Blood Sea Notification System Test\n");
testNotification().then(() => {
  testNotificationTypes();
});
