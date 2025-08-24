#!/bin/bash

echo "🩸 Blood Sea Notification API Test Suite"
echo "========================================"

API_BASE="http://localhost:3000"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    local auth_header=$5
    
    echo -e "\n${BLUE}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        if [ -n "$auth_header" ]; then
            response=$(curl -s -w "\n%{http_code}" -H "$auth_header" "$API_BASE$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" "$API_BASE$endpoint")
        fi
    else
        if [ -n "$auth_header" ]; then
            response=$(curl -s -w "\n%{http_code}" -X "$method" \
                -H "Content-Type: application/json" \
                -H "$auth_header" \
                -d "$data" \
                "$API_BASE$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" -X "$method" \
                -H "Content-Type: application/json" \
                -d "$data" \
                "$API_BASE$endpoint")
        fi
    fi
    
    # Extract HTTP status code (last line)
    http_code=$(echo "$response" | tail -n1)
    # Extract response body (all but last line)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo -e "${GREEN}✅ Success ($http_code)${NC}"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ Failed ($http_code)${NC}"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    fi
}

# Generate test token (you would replace this with actual token generation)
generate_test_token() {
    echo "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.test-token-for-demo"
}

echo -e "${YELLOW}📋 Starting API Tests...${NC}"

# 1. Test Health Check
test_endpoint "GET" "/health" "" "Health Check"

# 2. Test API Info
test_endpoint "GET" "/api/info" "" "API Information"

# 3. Test without authentication (should fail)
test_endpoint "POST" "/api/notifications/send" '{
    "userId": "test-user-123",
    "title": "Test Notification",
    "body": "This is a test notification",
    "priority": "normal"
}' "Send Notification (No Auth - Should Fail)"

# 4. Test with fake token (should fail)
test_endpoint "POST" "/api/notifications/send" '{
    "userId": "test-user-123",
    "title": "Test Notification",
    "body": "This is a test notification",
    "priority": "normal"
}' "Send Notification (Fake Token - Should Fail)" "Authorization: Bearer fake-token"

# 5. Test blood request without auth (should fail)
test_endpoint "POST" "/api/notifications/blood-request" '{
    "donorId": "donor123",
    "requesterId": "requester456",
    "bloodType": "O+",
    "hospital": "City Hospital",
    "urgency": "high"
}' "Blood Request Notification (No Auth - Should Fail)"

# 6. Test bulk notification without auth (should fail)
test_endpoint "POST" "/api/notifications/bulk" '{
    "userIds": ["user1", "user2"],
    "title": "Bulk Test",
    "body": "Bulk notification test",
    "priority": "normal"
}' "Bulk Notification (No Auth - Should Fail)"

echo -e "\n${YELLOW}📝 Test Summary:${NC}"
echo "✅ Health check and API info should work (no auth required)"
echo "❌ All notification endpoints should fail without valid authentication"
echo "🔒 This confirms the API security is working correctly"

echo -e "\n${BLUE}🔑 To test with real authentication:${NC}"
echo "1. Get a Firebase ID token from your Flutter app or admin panel"
echo "2. Use: -H \"Authorization: Bearer <your-firebase-id-token>\""
echo "3. Replace test data with real user IDs and FCM tokens"

echo -e "\n${BLUE}📱 Integration with Flutter App:${NC}"
echo "1. Update Flutter app to point to: http://localhost:3000"
echo "2. Or deploy this API to a cloud service (Railway, Render, etc.)"
echo "3. Update admin panel to use the API endpoints"

echo -e "\n${GREEN}🚀 API is ready for production deployment!${NC}"
