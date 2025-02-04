// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:blood_sea/config/routes.dart';
import 'package:blood_sea/config/theme.dart'; // Import your theme
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  if (kIsWeb) {
    // ✅ Register service worker FIRST
    final registration = await html.window.navigator.serviceWorker
        ?.register('/firebase-messaging-sw.js');

    if (registration != null) {
      print("✅ Service worker registered successfully!");

      // ✅ Now initialize FCM
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      print("❌ Failed to register service worker.");
    }
  }

  String? token = await messaging.getToken();
  if (kDebugMode) {
    print('Device Token: $token');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blood Sea',
      theme: AppTheme.lightTheme(),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
