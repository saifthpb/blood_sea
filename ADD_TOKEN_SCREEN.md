# 🔑 How to Add the Get Token Screen to Your App

## Quick Addition to Your Flutter App

### Option 1: Add as a Route (Recommended)

Add this to your `lib/config/router.dart`:

```dart
// Add this route to your GoRouter routes array
GoRoute(
  path: '/get-token',
  name: 'getToken',
  builder: (context, state) => const GetTokenScreen(),
),
```

Then navigate to it:
```dart
// From anywhere in your app
context.push('/get-token');

// Or using Navigator
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const GetTokenScreen()),
);
```

### Option 2: Add as a Drawer Item

Add this to your app drawer:

```dart
ListTile(
  leading: const Icon(Icons.security),
  title: const Text('Get Firebase Token'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GetTokenScreen()),
    );
  },
),
```

### Option 3: Add as a Debug Button

Add this anywhere in your app (temporarily):

```dart
// Add this import
import 'package:blood_sea/features/auth/get_token_screen.dart';

// Add this button
if (kDebugMode) // Only show in debug mode
  ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GetTokenScreen()),
      );
    },
    child: const Text('🔑 Get Token (Debug)'),
  ),
```

## What the Screen Does

1. ✅ Shows your current user information
2. ✅ Gets your Firebase ID token with one tap
3. ✅ Displays the token in a copyable format
4. ✅ Provides the exact export command to use
5. ✅ Shows usage instructions

## After Getting Your Token

1. Copy the token from the screen
2. Open your terminal
3. Run: `export FIREBASE_TOKEN="your_copied_token"`
4. Test the API: `./test-local.sh`

The token will look like:
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IjY4NzA5ZjkwYWY4YTQ4ZjU4ZGY3YzNkNzJkNzE4NzI2NjkzNzM4YzMiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vYmxvb2Qtc2VhLTU3ODE2IiwiYXVkIjoiYmxvb2Qtc2VhLTU3ODE2IiwiYXV0aF90aW1lIjoxNjk5MzY4NDAwLCJ1c2VyX2lkIjoiVGVzdFVzZXIxMjMiLCJzdWIiOiJUZXN0VXNlcjEyMyIsImlhdCI6MTY5OTM2ODQwMCwiZXhwIjoxNjk5MzcyMDAwLCJlbWFpbCI6InRlc3RAdGVzdC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJlbWFpbCI6WyJ0ZXN0QHRlc3QuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoicGFzc3dvcmQifX0...
```

This is much longer than the custom token and contains your actual user information.
