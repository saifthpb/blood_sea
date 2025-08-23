// Add this code to your Flutter app to get Firebase ID Token
// You can add this as a debug function or button

import 'package:firebase_auth/firebase_auth.dart';

Future<void> getFirebaseIdToken() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Get the ID token
      String idToken = await user.getIdToken();
      
      // Print it to console (for testing only!)
      print("=== FIREBASE ID TOKEN (FOR API TESTING) ===");
      print(idToken);
      print("=== END TOKEN ===");
      
      // You can also copy it to clipboard or show in UI
      // Clipboard.setData(ClipboardData(text: idToken));
      
    } else {
      print("No user logged in!");
    }
  } catch (e) {
    print("Error getting ID token: $e");
  }
}

// Usage: Call this function after user login
// Example: Add a debug button that calls getFirebaseIdToken()
