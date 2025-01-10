import 'package:blood_sea/config/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // Request permission for iOS
  NotificationSettings settings = await messaging.requestPermission();
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
    // Get the device token
  String? token = await messaging.getToken();
  if (kDebugMode) {
    print('Device Token: $token');
  } // Use this token in the Node.js script
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: goRouter,
    );
  }
}
