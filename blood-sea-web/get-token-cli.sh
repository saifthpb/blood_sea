#!/bin/bash

# Get Firebase ID Token using Firebase CLI
# This script helps you get an ID token using Firebase CLI

echo "🔑 Getting Firebase ID Token via CLI"
echo "======================================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not installed!"
    echo ""
    echo "Install Firebase CLI:"
    echo "npm install -g firebase-tools"
    echo ""
    echo "Or use curl:"
    echo "curl -sL https://firebase.tools | bash"
    exit 1
fi

echo "✅ Firebase CLI found"

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase"
    echo ""
    echo "Please login first:"
    echo "firebase login"
    exit 1
fi

echo "✅ Firebase CLI authenticated"

# Try to get the current project
PROJECT_ID=$(firebase use --json 2>/dev/null | jq -r '.result.projectId // empty')

if [ -z "$PROJECT_ID" ]; then
    echo "⚠️ No active Firebase project set"
    echo ""
    echo "Available projects:"
    firebase projects:list
    echo ""
    echo "Set your project:"
    echo "firebase use blood-sea-57816"
    echo ""
    read -p "Enter your project ID: " PROJECT_ID
    
    if [ -n "$PROJECT_ID" ]; then
        firebase use "$PROJECT_ID"
    else
        echo "❌ No project ID provided"
        exit 1
    fi
fi

echo "✅ Using project: $PROJECT_ID"
echo ""

echo "🔧 Note: Firebase CLI doesn't directly provide user ID tokens"
echo "You'll need to use one of these alternatives:"
echo ""

echo "1. 📱 From your Flutter app (recommended):"
echo "   - Add the code from flutter_get_token.dart to your app"
echo "   - Login with a test user"
echo "   - The token will be printed to console"
echo ""

echo "2. 🌐 From web browser:"
echo "   - Open get-firebase-token.html in your browser"
echo "   - Update the Firebase config with your project settings"
echo "   - Sign in and copy the token"
echo ""

echo "3. 🔧 Firebase Auth REST API:"
echo "   - Use the Firebase Auth REST API to sign in"
echo "   - Exchange credentials for ID token"
echo ""

echo "📋 Your Project Details:"
echo "Project ID: $PROJECT_ID"
echo "Auth Domain: $PROJECT_ID.firebaseapp.com"

# Get Firebase config if available
if [ -f ".firebaserc" ]; then
    echo ""
    echo "📁 Firebase config found (.firebaserc):"
    cat .firebaserc
fi

if [ -f "firebase.json" ]; then
    echo ""
    echo "📁 Firebase hosting config found (firebase.json):"
    cat firebase.json | head -20
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Create a test user in Firebase Console → Authentication"
echo "2. Use the HTML file (get-firebase-token.html) to sign in and get token"
echo "3. Or add the Flutter code to your app to extract the token"
echo "4. Use the token to test your API endpoints"
