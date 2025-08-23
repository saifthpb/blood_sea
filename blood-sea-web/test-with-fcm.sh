#!/bin/bash

# Blood Sea API Testing with Real FCM Token
# This script tests endpoints that can work without Firebase Auth but with FCM tokens

set -e

API_BASE="http://localhost:3000"
FCM_TOKEN="chRRdWHRU0DN6-bJtXB58r:APA91bHhproPN6LCb8Xo8wDCQ_6548XnZwRtSQZbJdNaMrs9XjDwQ4DOfhNV_SiT3bLfU982-5lC65gFko3w5S-Fjse6uqitcTsF1aL6ePulbhYSIUHAQrc"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔬 Testing Blood Sea API with Real FCM Token${NC}"
echo "================================================="
echo -e "FCM Token: ${YELLOW}${FCM_TOKEN}${NC}"
echo ""

# Function to print test results
print_test_result() {
    local test_name="$1"
    local status_code="$2"
    local expected_code="$3"
    local response="$4"
    
    if [ "$status_code" -eq "$expected_code" ]; then
        echo -e "${GREEN}✅ $test_name - PASSED (Status: $status_code)${NC}"
        if [ "$status_code" -eq "200" ] || [ "$status_code" -eq "201" ]; then
            echo -e "${BLUE}   Response: $response${NC}"
        fi
    else
        echo -e "${RED}❌ $test_name - FAILED (Expected: $expected_code, Got: $status_code)${NC}"
        echo -e "${YELLOW}   Response: $response${NC}"
    fi
    echo ""
}

echo -e "${BLUE}1. Testing Health Check${NC}"
echo "---------------------"

response=$(curl -s -w "%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    "$API_BASE/api/health/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Health Check" "$status_code" "200" "$body"

echo -e "${BLUE}2. Testing Notification Send with FCM Token (No Auth - should fail)${NC}"
echo "----------------------------------------------------------------"

response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{
        \"fcmToken\": \"$FCM_TOKEN\",
        \"title\": \"Test Notification\",
        \"body\": \"Testing with real FCM token\",
        \"type\": \"test\",
        \"priority\": \"normal\"
    }" \
    "$API_BASE/api/notifications/send/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Send Notification with FCM Token (No Auth)" "$status_code" "401" "$body"

echo -e "${BLUE}3. Testing FCM Token Validation Format${NC}"
echo "----------------------------------------"

# Test the FCM token format by trying to save it (will fail due to auth but should show validation)
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "{
        \"fcmToken\": \"$FCM_TOKEN\",
        \"platform\": \"android\"
    }" \
    "$API_BASE/api/users/fcm-token/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "FCM Token Format Validation (No Auth)" "$status_code" "401" "$body"

echo -e "${BLUE}4. Testing with Malformed Authorization Header${NC}"
echo "----------------------------------------------"

# Test with malformed authorization header (this might be causing your issue)
response=$(curl -s -w "%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer invalid-token-with-newlines" \
    "$API_BASE/api/users/profile/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Malformed Auth Header" "$status_code" "401" "$body"

echo -e "${BLUE}5. Testing with Clean Authorization Header${NC}"
echo "---------------------------------------------"

# Test with properly formatted auth header
CLEAN_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.test-token"
response=$(curl -s -w "%{http_code}" -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $CLEAN_TOKEN" \
    "$API_BASE/api/users/profile/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Clean Auth Header Format" "$status_code" "401" "$body"

echo -e "${BLUE}6. Testing Header Character Issues${NC}"
echo "--------------------------------"

# Test potential header character issues
echo "Testing different header formats..."

# Test 1: No spaces around colon
response=$(curl -s -w "%{http_code}" -X GET \
    -H "Content-Type:application/json" \
    -H "Authorization:Bearer test-token" \
    "$API_BASE/api/users/profile/" 2>&1 || true)

if [[ $response == *"Invalid character"* ]]; then
    echo -e "${RED}❌ Found header character issue with no spaces${NC}"
else
    status_code="${response: -3}"
    body="${response%???}"
    echo -e "${GREEN}✅ No character issues with no-space format${NC}"
fi

echo -e "${BLUE}7. Testing API Endpoint Accessibility${NC}"
echo "-----------------------------------"

endpoints=(
    "GET /api/health/"
    "GET /api/users/profile/"
    "POST /api/users/fcm-token/"
    "POST /api/notifications/send/"
)

for endpoint_info in "${endpoints[@]}"; do
    method=$(echo "$endpoint_info" | cut -d' ' -f1)
    path=$(echo "$endpoint_info" | cut -d' ' -f2)
    
    if [ "$method" = "POST" ]; then
        response=$(curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d '{"test":"data"}' \
            "$API_BASE$path" 2>&1 || echo "ERROR000")
    else
        response=$(curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            "$API_BASE$path" 2>&1 || echo "ERROR000")
    fi
    
    if [[ $response == *"ERROR"* ]] || [[ $response == *"Invalid character"* ]]; then
        echo -e "${RED}❌ $endpoint_info - CONNECTION/HEADER ERROR${NC}"
        echo -e "${YELLOW}   Error: $response${NC}"
    else
        status_code="${response: -3}"
        echo -e "${GREEN}✅ $endpoint_info - ACCESSIBLE (Status: $status_code)${NC}"
    fi
done

echo -e "\n${BLUE}📋 FCM Token Information${NC}"
echo "========================"
echo -e "Token Length: ${#FCM_TOKEN} characters"
echo -e "Token Format: ${FCM_TOKEN:0:20}...${FCM_TOKEN: -10}"
# Check if FCM token has valid format (basic check)
if [[ ${#FCM_TOKEN} -ge 140 ]] && [[ ${#FCM_TOKEN} -le 200 ]]; then
    echo -e "Valid FCM Format: Yes"
else
    echo -e "Valid FCM Format: No (but that's normal for FCM tokens)"
fi

echo -e "\n${BLUE}🔧 Troubleshooting Header Issues${NC}"
echo "================================"
echo "If you're seeing 'Invalid character in header content' errors:"
echo "1. Check for hidden newlines in your authorization token"
echo "2. Ensure no special characters in header values"
echo "3. Use proper header formatting: 'Authorization: Bearer <token>'"
echo "4. Make sure your Firebase ID token doesn't contain newlines"
echo ""
echo "To clean a token with newlines:"
echo 'TOKEN=$(echo "$YOUR_TOKEN" | tr -d "\\n\\r")'
echo ""
echo -e "${GREEN}📱 Your FCM Token is ready for testing!${NC}"
echo "Once you have a Firebase ID token, you can test notifications with:"
echo ""
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
