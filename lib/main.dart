// dart:html removed - not available on mobile platforms
// If you need web-specific functionality, use conditional imports:
// import 'dart:html' as html if (dart.library.html) 'dart:html';
import 'package:blood_sea/config/router.dart';
import 'package:blood_sea/config/theme.dart'; // Import your theme
import 'package:blood_sea/core/di/injection.dart';
import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:blood_sea/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'firebase_options.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
  
  // Handle background notification logic here
  if (message.data['type'] == 'blood_request') {
    print('Background blood request notification received');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize FCM Service
  await FCMService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
        onRetry: () {print("on retry main.dart");},
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthBloc(userRepository)),
          ],
          child: Builder(
            builder: (context) => MaterialApp.router(
              title: 'Blood Sea',
              theme: ThemeData(
                  primarySwatch: Colors.red,
                  visualDensity: VisualDensity.adaptivePlatformDensity),
              routerConfig: createRouter(context),
              debugShowCheckedModeBanner: false,
            ),
          ),
        ));
  }
}
