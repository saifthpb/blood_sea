import 'dart:async';

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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState is Authenticated;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/client-signup',
          name: 'clientSignup',
          builder: (context, state) => ClientSignUpScreen(),
        ),
        GoRoute(
          path: '/donor-registration',
          name: 'donorRegistration',
          builder: (context, state) => const DonorRegistrationScreen(),
        ),
        GoRoute(
          path: '/user-registration',
          name: 'userRegistration',
          builder: (context, state) => const UserRegistrationScreen(),
        ),
        // Public routes that don't require authentication
        GoRoute(
          path: '/privacy-policy',
          name: 'privacyPolicy',
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/contact',
          name: 'contact',
          builder: (context, state) => const ContactScreen(),
        ),

        // Protected routes under ShellRoute with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            final location = state.uri.toString();
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated) {
                  return LoginScreen();
                }

                final user = authState.userModel;

                return Scaffold(
                  appBar: AppBar(
                    title: Text(_getAppBarTitle(location)),
                    backgroundColor: location.startsWith('/notifications')
                        ? Colors.blue
                        : Colors.redAccent,
                    actions: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          user.name?.substring(0, 1).toUpperCase() ??
                              user.email.substring(0, 1).toUpperCase(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ],
                  ),
                  body: child,
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _getSelectedIndex(location),
                    onTap: (index) {
                      switch (index) {
                        case 0:
                          context.goNamed('home');
                          break;
                        case 1:
                          context.goNamed('donorList');
                          break;
                        case 2:
                          context.goNamed('profile');
                          break;
                        case 3:
                          context.goNamed('notifications');
                          break;
                      }
                    },
                    items: const [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.list), label: 'Donor List'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.notifications),
                          label: 'Notifications'),
                    ],
                  ),
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      return HomeScreen(user: state.userModel);
                    }
                    return const HomeScreen();
                  },
                );
              },
            ),
            GoRoute(
              path: '/donor-list',
              name: 'donorList',
              builder: (context, state) => const DonorListScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationScreen(),
            ),
            // Additional protected routes
            GoRoute(
              path: '/client-area',
              name: 'clientArea',
              builder: (context, state) => const ClientAreaScreen(),
            ),
            GoRoute(
              path: '/donor-search',
              name: 'donorSearch',
              builder: (context, state) => const DonorSearchScreen(),
            ),
            GoRoute(
              path: '/donors-area',
              name: 'donorsArea',
              builder: (context, state) => const DonorsAreaScreen(),
            ),
            GoRoute(
              path: '/request',
              name: 'request',
              builder: (context, state) => const RequestScreen(),
            ),
            GoRoute(
              path: '/search-result',
              name: 'searchResult',
              builder: (context, state) => const SearchResultScreen(),
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/share',
              name: 'share',
              builder: (context, state) => const ShareScreen(),
            ),
          ],
        ),
      ],
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ));
}

// Helper functions remain the same
String _getAppBarTitle(String location) {
  switch (location) {
    case '/home':
      return 'Home';
    case '/donor-list':
      return 'Donor List';
    case '/profile':
      return 'Profile';
    case '/notifications':
      return 'Notifications';
    case '/client-area':
      return 'Client Area';
    case '/donor-search':
      return 'Search Donors';
    case '/donors-area':
      return 'Donors Area';
    case '/request':
      return 'Make Request';
    case '/search':
      return 'Search';
    case '/search-result':
      return 'Search Results';
    case '/share':
      return 'Share';
    default:
      return 'Blood Sea';
  }
}

int _getSelectedIndex(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/donor-list')) return 1;
  if (location.startsWith('/profile')) return 2;
  if (location.startsWith('/notifications')) return 3;
  return 0;
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
