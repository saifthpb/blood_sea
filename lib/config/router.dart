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
import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/bloc/auth_bloc.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
        title: 'Navigation Error',
        onRetry: () => context.go('/home'),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) {
              return LoginScreen();
            }

            final location = GoRouterState.of(context).uri.toString();
            final user = state.userModel;

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
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.grey,
                onTap: (index) => _onItemTapped(index, context),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Donor List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: 'Notifications',
                  ),
                ],
              ),
            );
          },
        ));
  }

  String _getAppBarTitle(String location) {
    if (location.startsWith('/home')) return 'Home';
    if (location.startsWith('/donor-list')) return 'Donor List';
    if (location.startsWith('/profile')) return 'Profile';
    if (location.startsWith('/notifications')) return 'Notifications';
    return 'Blood Sea';
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/donor-list')) return 1;
    if (location.startsWith('/profile')) return 2;
    if (location.startsWith('/notifications')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
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
  }
}

GoRouter createRouter(BuildContext context) {
  return GoRouter(
      navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
      initialLocation: '/',
      redirect: (context, state) {
        // Don't redirect if we're on the splash screen
        if (state.uri.toString() == '/') {
          return null;
        }

        final authState = context.read<AuthBloc>().state;
        final isLoggedIn = authState is Authenticated;
        final isLoggingIn = state.uri.toString() == '/login';
        final isSplash = state.uri.toString() == '/';

        // Allow access to splash screen
        if (isSplash) return null;

        // Handle other redirects
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
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/client-signup',
          name: 'clientSignup',
          builder: (context, state) => const ClientSignUpScreen(),
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
        // Protected routes under ShellRoute with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScreen(child: child);
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
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ));
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
