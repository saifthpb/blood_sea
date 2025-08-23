#!/bin/bash

# Blood Sea Notification API - Local Testing Script
echo "🧪 Testing Blood Sea Notification API locally..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API Base URL
API_URL="http://localhost:3000"

# Test if server is running
echo -e "${BLUE}🔍 Checking if API server is running...${NC}"
if ! curl -s "$API_URL/health" > /dev/null; then
    echo -e "${RED}❌ API server is not running on $API_URL${NC}"
    echo -e "${YELLOW}💡 Start the server with: npm run dev${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API server is running${NC}"

# Test health endpoint
echo -e "\n${BLUE}🏥 Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s "$API_URL/health")
echo -e "${GREEN}Response:${NC} $HEALTH_RESPONSE"

# Check if we have a Firebase token for testing
if [ -z "$FIREBASE_TOKEN" ]; then
    echo -e "\n${YELLOW}⚠️  No Firebase token provided for authenticated tests${NC}"
    echo -e "${YELLOW}💡 To test authenticated endpoints:${NC}"
    echo -e "${YELLOW}   1. Get a Firebase ID token from your Flutter app${NC}"
    echo -e "${YELLOW}   2. Run: export FIREBASE_TOKEN='your_token_here'${NC}"
    echo -e "${YELLOW}   3. Run this script again${NC}"
    echo -e "\n${BLUE}📋 Available unauthenticated tests:${NC}"
    echo -e "   • Health check: ✅ Passed"
    exit 0
fi

echo -e "\n${GREEN}🔑 Firebase token found, running authenticated tests...${NC}"

# Test FCM token update
echo -e "\n${BLUE}📱 Testing FCM token update...${NC}"
FCM_RESPONSE=$(curl -s -X POST "$API_URL/api/users/fcm-token" \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fcmToken": "test_fcm_token_123",
    "platform": "android"
  }')

if echo "$FCM_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ FCM token update: PASSED${NC}"
else
    echo -e "${RED}❌ FCM token update: FAILED${NC}"
    echo -e "${YELLOW}Response: $FCM_RESPONSE${NC}"
fi

# Test notification settings
echo -e "\n${BLUE}⚙️ Testing notification settings update...${NC}"
SETTINGS_RESPONSE=$(curl -s -X PUT "$API_URL/api/users/notification-settings" \
  -H "Authorization: Bearer $FIREBASE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bloodRequests": true,
    "emergencyRequests": true,
    "generalAnnouncements": false,
    "soundEnabled": true
  }')

if echo "$SETTINGS_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ Notification settings: PASSED${NC}"
else
    echo -e "${RED}❌ Notification settings: FAILED${NC}"
    echo -e "${YELLOW}Response: $SETTINGS_RESPONSE${NC}"
fi

# Test sending a test notification
echo -e "\n${BLUE}🔔 Testing test notification...${NC}"
TEST_NOTIF_RESPONSE=$(curl -s -X POST "$API_URL/api/users/test-notification" \
  -H "Authorization: Bearer $FIREBASE_TOKEN")

if echo "$TEST_NOTIF_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ Test notification: PASSED${NC}"
else
    echo -e "${RED}❌ Test notification: FAILED${NC}"
    echo -e "${YELLOW}Response: $TEST_NOTIF_RESPONSE${NC}"
fi

# Test blood request notification (requires donor ID)
if [ ! -z "$DONOR_ID" ]; then
    echo -e "\n${BLUE}🩸 Testing blood request notification...${NC}"
    BLOOD_REQUEST_RESPONSE=$(curl -s -X POST "$API_URL/api/notifications/blood-request" \
      -H "Authorization: Bearer $FIREBASE_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{
        \"donorId\": \"$DONOR_ID\",
        \"requesterId\": \"test_requester_123\",
        \"requesterName\": \"Test User\",
        \"requesterPhone\": \"+1234567890\",
        \"bloodType\": \"A+\",
        \"location\": \"Test Hospital, Test City\",
        \"urgency\": \"urgent\",
        \"requiredDate\": \"$(date -d '+1 day' -Iseconds)\",
        \"additionalMessage\": \"This is a test blood request\"
      }")

    if echo "$BLOOD_REQUEST_RESPONSE" | grep -q '"success":true'; then
        echo -e "${GREEN}✅ Blood request notification: PASSED${NC}"
    else
        echo -e "${RED}❌ Blood request notification: FAILED${NC}"
        echo -e "${YELLOW}Response: $BLOOD_REQUEST_RESPONSE${NC}"
    fi
else
    echo -e "\n${YELLOW}⚠️  Skipping blood request test (no DONOR_ID provided)${NC}"
    echo -e "${YELLOW}💡 To test blood requests: export DONOR_ID='donor_user_id'${NC}"
fi

# Test getting user notifications
echo -e "\n${BLUE}📋 Testing get user notifications...${NC}"
NOTIF_LIST_RESPONSE=$(curl -s "$API_URL/api/notifications/user/test_user_123?limit=5" \
  -H "Authorization: Bearer $FIREBASE_TOKEN")

if echo "$NOTIF_LIST_RESPONSE" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ Get notifications: PASSED${NC}"
else
    echo -e "${RED}❌ Get notifications: FAILED${NC}"
    echo -e "${YELLOW}Response: $NOTIF_LIST_RESPONSE${NC}"
fi

echo -e "\n${GREEN}🎉 Testing complete!${NC}"
echo -e "\n${BLUE}📊 Test Summary:${NC}"
echo -e "   • Health check: ✅"
echo -e "   • FCM token update: $(echo "$FCM_RESPONSE" | grep -q '"success":true' && echo "✅" || echo "❌")"
echo -e "   • Notification settings: $(echo "$SETTINGS_RESPONSE" | grep -q '"success":true' && echo "✅" || echo "❌")"
echo -e "   • Test notification: $(echo "$TEST_NOTIF_RESPONSE" | grep -q '"success":true' && echo "✅" || echo "❌")"
echo -e "   • Get notifications: $(echo "$NOTIF_LIST_RESPONSE" | grep -q '"success":true' && echo "✅" || echo "❌")"

echo -e "\n${BLUE}📝 View detailed logs:${NC}"
echo -e "   • Combined logs: ${GREEN}tail -f logs/combined.log${NC}"
echo -e "   • Error logs: ${GREEN}tail -f logs/error.log${NC}"
echo -e "   • Notification logs: ${GREEN}tail -f logs/notifications.log${NC}"
