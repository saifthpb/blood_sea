#!/bin/bash

# Blood Sea - Complete Local Testing Setup
echo "🩸 Blood Sea Notification System - Local Testing Setup"
echo "═══════════════════════════════════════════════════════"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}💡 $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the blood_sea project root directory"
    exit 1
fi

print_step "Step 1: Setting up Node.js API server..."

# Navigate to API directory
cd notification-api

# Check if setup script exists
if [ ! -f "setup-local.sh" ]; then
    print_error "setup-local.sh not found. Please ensure all files are created."
    exit 1
fi

# Run setup
print_info "Running API setup..."
./setup-local.sh

if [ $? -ne 0 ]; then
    print_error "API setup failed"
    exit 1
fi

print_success "API setup completed"

# Check if .env file needs configuration
if grep -q "your_private_key_id" .env 2>/dev/null; then
    print_warning "Firebase credentials not configured in .env file"
    print_info "Please follow these steps:"
    echo "  1. Go to Firebase Console: https://console.firebase.google.com/project/blood-sea-57816/settings/serviceaccounts/adminsdk"
    echo "  2. Click 'Generate new private key'"
    echo "  3. Download the JSON file"
    echo "  4. Update .env file with the credentials"
    echo ""
    read -p "Press Enter after configuring Firebase credentials..."
fi

print_step "Step 2: Starting API server..."

# Start API server in background
print_info "Starting API server on port 3000..."
npm run dev &
API_PID=$!

# Wait for server to start
sleep 5

# Check if server is running
if curl -s http://localhost:3000/health > /dev/null; then
    print_success "API server is running (PID: $API_PID)"
else
    print_error "API server failed to start"
    kill $API_PID 2>/dev/null
    exit 1
fi

print_step "Step 3: Testing API endpoints..."

# Run API tests
./test-local.sh

print_step "Step 4: Flutter app configuration..."

cd ..

# Check if enhanced notification service exists
if [ ! -f "lib/services/notification_service_enhanced.dart" ]; then
    print_warning "Enhanced notification service not found"
    print_info "Please ensure notification_service_enhanced.dart is created in lib/services/"
else
    print_success "Enhanced notification service found"
fi

# Check if test screen exists
if [ ! -f "lib/features/notifications/screens/notification_test_screen.dart" ]; then
    print_warning "Notification test screen not found"
    print_info "Please ensure notification_test_screen.dart is created"
else
    print_success "Notification test screen found"
fi

print_step "Step 5: Firebase token generation..."

cd notification-api

# Generate Firebase token for testing
print_info "Generating Firebase test token..."
node get-firebase-token.js

print_step "Step 6: Complete testing instructions..."

echo ""
echo -e "${GREEN}🎉 Local setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Next Steps:${NC}"
echo "1. Update Flutter app configuration:"
echo "   • Open lib/services/notification_service_enhanced.dart"
echo "   • Change API URL to: http://localhost:3000/api"
echo "   • For Android emulator use: http://10.0.2.2:3000/api"
echo ""
echo "2. Add test screen to your Flutter app:"
echo "   • Import: import 'package:blood_sea/features/notifications/screens/notification_test_screen.dart';"
echo "   • Add route in router.dart"
echo "   • Or navigate directly: Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationTestScreen()));"
echo ""
echo "3. Test the system:"
echo "   • Run your Flutter app"
echo "   • Navigate to the notification test screen"
echo "   • Try sending test notifications"
echo ""
echo -e "${BLUE}🔧 Monitoring:${NC}"
echo "   • API logs: tail -f notification-api/logs/combined.log"
echo "   • Error logs: tail -f notification-api/logs/error.log"
echo "   • Health check: curl http://localhost:3000/health"
echo ""
echo -e "${BLUE}🧪 Manual Testing:${NC}"
echo "   • Get Firebase token from Flutter app or use generated token above"
echo "   • Export token: export FIREBASE_TOKEN='your_token_here'"
echo "   • Run tests: cd notification-api && ./test-local.sh"
echo ""
echo -e "${BLUE}🛑 To Stop:${NC}"
echo "   • Stop API server: kill $API_PID"
echo "   • Or use: pkill -f 'node.*server.js'"
echo ""

# Function to cleanup on exit
cleanup() {
    print_info "Cleaning up..."
    kill $API_PID 2>/dev/null
    print_success "API server stopped"
}

# Set trap to cleanup on script exit
trap cleanup EXIT

print_info "API server is running in background (PID: $API_PID)"
print_info "Press Ctrl+C to stop the server and exit"

# Keep script running
while true; do
    sleep 1
done
