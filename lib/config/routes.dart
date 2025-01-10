import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:blood_sea/features/donors/donor_list_screen.dart';
import 'package:blood_sea/features/home/home_screen.dart';
import 'package:blood_sea/features/notifications/notifications_screen.dart';
import 'package:blood_sea/features/profile/profile_screen.dart';
import 'package:blood_sea/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
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

export 'routes.dart';

// Helper for AppBar title
String _getAppBarTitle(String location) {
  if (location.startsWith('/donor-list')) return 'Donor List';
  if (location.startsWith('/profile')) return 'Profile';
  if (location.startsWith('/notifications')) return 'Notifications';
  return 'Home';
}

// Helper for BottomNavigationBar index
int _getSelectedIndex(String location) {
  if (location.startsWith('/donor-list')) return 1;
  if (location.startsWith('/profile')) return 2;
  if (location.startsWith('/notifications')) return 3;
  return 0;
}
