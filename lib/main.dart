import 'package:blood_sea/config/routes.dart';
import 'package:blood_sea/config/theme.dart'; // Import your theme
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
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
