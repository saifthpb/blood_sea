# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running the App
- `flutter run` - Run the app in debug mode
- `flutter run --release` - Run in release mode
- `flutter run -d web` - Run on web platform
- `flutter run -d android` - Run on Android
- `flutter run -d ios` - Run on iOS

### Code Generation
- `flutter packages pub run build_runner build` - Generate code for json_serializable and other code generators
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force regenerate all generated files

### Testing and Analysis
- `flutter test` - Run unit and widget tests
- `flutter analyze` - Run static analysis using analysis_options.yaml
- `flutter doctor` - Check Flutter installation and dependencies

### Dependencies
- `flutter pub get` - Install dependencies from pubspec.yaml
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter clean` - Clean build artifacts

## Architecture Overview

### Project Structure
This is a Flutter blood donation app using Firebase as the backend with the following architecture:

**State Management**: BLoC pattern with flutter_bloc
- Each feature has its own bloc for state management
- Main blocs: AuthBloc, DonorBloc, NotificationBloc, ProfileBloc

**Navigation**: GoRouter for declarative routing
- Protected routes require authentication
- Shell routes provide consistent bottom navigation
- Route configuration in `lib/config/router.dart`

**Dependency Injection**: Simple DI pattern in `lib/core/di/injection.dart`
- UserRepository and AuthBloc are globally available singletons

### Key Features Structure
- **Authentication** (`lib/features/auth/`): Login, signup, user management
- **Donors** (`lib/features/donors/`): Donor listing, search, details, blood requests
- **Notifications** (`lib/features/notifications/`): Firebase messaging integration
- **Profile** (`lib/features/profile/`): User profile management

### Firebase Integration
- **Authentication**: Firebase Auth for user login/registration
- **Database**: Cloud Firestore for user data, donor information, notifications
- **Storage**: Firebase Storage for user profile images
- **Messaging**: Firebase Cloud Messaging for notifications
- Configuration in `firebase_options.dart` (auto-generated)

### Models and Data
- User types: 'donor' and 'client'
- Blood group filtering and location-based search
- Notification system with real-time updates
- User status tracking (online/offline)

### UI Components
- Custom drawer (`lib/shared/widgets/drawer.dart`)
- Error boundary for error handling (`lib/shared/widgets/error_boundary.dart`)
- Donor cards and notification cards as reusable widgets

### Code Generation
Uses `json_serializable` and `build_runner` for model serialization. Generated files have `.g.dart` extension and are excluded from analysis.

### Linting
Uses `flutter_lints` with additional rule `always_declare_return_types` in `analysis_options.yaml`.