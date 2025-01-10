import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:blood_sea/features/donors/donor_list_screen.dart';
import 'package:blood_sea/features/home/home_screen.dart';
import 'package:blood_sea/features/notifications/notifications_screen.dart';
import 'package:blood_sea/features/privacy_policy/privacy_policy_screen.dart';
import 'package:blood_sea/features/profile/profile_screen.dart';
import 'package:blood_sea/features/share/share_screen.dart';
import 'package:blood_sea/features/splash/splash_screen.dart';
import 'package:blood_sea/features/auth/client_signup_screen.dart';
import 'package:blood_sea/features/auth/donor_registration_screen.dart';
import 'package:blood_sea/features/auth/user_registration_screen.dart';
import 'package:blood_sea/features/clients/client_area_screen.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';
import 'package:blood_sea/features/donors/donor_search_screen.dart';
import 'package:blood_sea/features/donors/donors_area_screen.dart';
import 'package:blood_sea/features/donors/request_screen.dart';
import 'package:blood_sea/features/donors/search_result_screen.dart';
import 'package:blood_sea/features/donors/search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    // Don't redirect if we're already going to splash
    if (state.uri.toString() == '/splash') {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;
    
    // If user is not authenticated and not going to login, redirect to login
    if (user == null && state.uri.toString() != '/login') {
      return '/login';
    }

    // If user is authenticated and trying to access login/splash, redirect to home
    if (user != null && (state.uri.toString() == '/login' || state.uri.toString() == '/splash')) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(
        onInit: () async {
          // Wait for 2 seconds
          await Future.delayed(const Duration(seconds: 2));
          
          if (FirebaseAuth.instance.currentUser != null) {
            if (context.mounted) context.go('/home');
          } else {
            if (context.mounted) context.go('/login');
          }
        },
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/client-signup',
      builder: (context, state) => ClientSignUpScreen(),
    ),
    GoRoute(
      path: '/donor-registration',
      builder: (context, state) => const DonorRegistrationScreen(),
    ),
    GoRoute(
      path: '/user-registration',
      builder: (context, state) => const UserRegistrationScreen(),
    ),
    GoRoute(
      path: '/client-area',
      builder: (context, state) => const ClientAreaScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/donor-search',
      builder: (context, state) => const DonorSearchScreen(),
    ),
    GoRoute(
      path: '/donors-area',
      builder: (context, state) => const DonorsAreaScreen(),
    ),
    GoRoute(
      path: '/request',
      builder: (context, state) => const RequestScreen(),
    ),
    GoRoute(
      path: '/search-result',
      builder: (context, state) => const SearchResultScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/share',
      builder: (context, state) => const ShareScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(location)),
            backgroundColor: location.startsWith('/notifications')
                ? Colors.blue
                : Colors.redAccent,
          ),
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _getSelectedIndex(location),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/donor-list');
                  break;
                case 2:
                  context.go('/profile');
                  break;
                case 3:
                  context.go('/notifications');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Donor List'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Notifications'),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/donor-list',
          builder: (context, state) => const DonorListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
      ],
    ),
  ],
);

// Helper functions remain the same
String _getAppBarTitle(String location) {
  if (location.startsWith('/donor-list')) return 'Donor List';
  if (location.startsWith('/profile')) return 'Profile';
  if (location.startsWith('/notifications')) return 'Notifications';
  return 'Home';
}

int _getSelectedIndex(String location) {
  if (location.startsWith('/donor-list')) return 1;
  if (location.startsWith('/profile')) return 2;
  if (location.startsWith('/notifications')) return 3;
  return 0;
}
