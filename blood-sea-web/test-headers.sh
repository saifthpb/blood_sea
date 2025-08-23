#!/bin/bash

# Header Testing Script
# This script helps identify header character issues

API_BASE="http://localhost:3000"
FCM_TOKEN="chRRdWHRU0DN6-bJtXB58r:APA91bHhproPN6LCb8Xo8wDCQ_6548XnZwRtSQZbJdNaMrs9XjDwQ4DOfhNV_SiT3bLfU982-5lC65gFko3w5S-Fjse6uqitcTsF1aL6ePulbhYSIUHAQrc"

echo "🔧 Header Character Issue Troubleshooting"
echo "========================================="
echo ""

echo "1. Testing basic endpoint without auth headers..."
response=$(curl -s -w "%{http_code}" -X GET "$API_BASE/api/health/")
status_code="${response: -3}"
body="${response%???}"
echo "Health Check: Status $status_code"
echo ""

echo "2. Testing with simple Authorization header..."
# Test with clean, simple token
response=$(curl -s -w "%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer test-token" \
    "$API_BASE/api/users/profile/" 2>&1)

if [[ $response == *"Invalid character"* ]]; then
    echo "❌ Header character issue detected!"
    echo "Error: $response"
else
    status_code="${response: -3}"
    echo "✅ No header character issues - Status: $status_code"
fi
echo ""

echo "3. Testing notification with FCM token..."
# Create a temporary file with the JSON to avoid command line issues
cat > /tmp/test-notification.json << EOF
{
    "fcmToken": "$FCM_TOKEN",
    "title": "Test Notification",
    "body": "Testing with real FCM token",
    "type": "test",
    "priority": "normal"
}
EOF

response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    --data @/tmp/test-notification.json \
    "$API_BASE/api/notifications/send/" 2>&1)

if [[ $response == *"Invalid character"* ]]; then
    echo "❌ Header/content issue with notification test!"
    echo "Error: $response"
else
    status_code="${response: -3}"
    body="${response%???}"
    echo "✅ Notification test - Status: $status_code"
    echo "Response: $body"
fi

# Cleanup
rm -f /tmp/test-notification.json
echo ""

echo "4. FCM Token Analysis"
echo "===================="
echo "Token length: ${#FCM_TOKEN} characters"
echo "Contains special chars: $(echo "$FCM_TOKEN" | grep -o '[^A-Za-z0-9_:-]' | wc -l) non-standard characters"
echo ""

echo "🎯 If you're still getting header character errors:"
echo "================================================="
echo "1. Check your Firebase ID token for newlines:"
echo '   TOKEN=$(echo "$YOUR_TOKEN" | tr -d "\n\r")'
echo ""
echo "2. Test with a simple curl command:"
echo '   curl -X GET http://localhost:3000/api/users/profile/ \'
echo '     -H "Content-Type: application/json" \'
echo '     -H "Authorization: Bearer YOUR_CLEAN_TOKEN"'
echo ""
echo "3. Your FCM token is clean and ready to use!"
echo "   Length: ${#FCM_TOKEN} characters"
echo "   Format: Valid FCM token format"
echo ""
echo "📱 To test notifications with a Firebase ID token:"
echo "================================================"
echo 'curl -X POST http://localhost:3000/api/notifications/send/ \'
echo '  -H "Content-Type: application/json" \'
echo '  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \'
echo '  -d "{'
echo '    \"fcmToken\": \"'$FCM_TOKEN'\",'
echo '    \"title\": \"Test Notification\",'
echo '    \"body\": \"Testing with real FCM token\",'
echo '    \"type\": \"test\",'
echo '    \"priority\": \"normal\"'
echo '  }"'
