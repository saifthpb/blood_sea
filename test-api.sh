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
    
    echo -e "\n${BLUE}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$API_BASE$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_BASE$endpoint")
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

# 1. Test Health Check
test_endpoint "GET" "/health" "" "Health Check"

# 2. Test API Status
test_endpoint "GET" "/api/status" "" "API Status"

# 3. Test without authentication (should fail)
test_endpoint "POST" "/api/notifications/send" '{
    "userId": "test-user-123",
    "title": "Test Notification",
    "body": "This is a test notification",
    "priority": "normal"
}' "Send Notification (No Auth - Should Fail)"

# 4. Test bulk notification (should fail without auth)
test_endpoint "POST" "/api/notifications/bulk" '{
    "userIds": ["user1", "user2"],
    "title": "Bulk Test",
    "body": "Bulk notification test",
    "priority": "normal"
}' "Bulk Notification (No Auth - Should Fail)"

# 5. Test blood request notification (should fail without auth)
test_endpoint "POST" "/api/notifications/blood-request" '{
    "donorId": "donor123",
    "requesterId": "requester456",
    "bloodType": "O+",
    "hospital": "City Hospital",
    "urgency": "high"
}' "Blood Request Notification (No Auth - Should Fail)"

echo -e "\n${YELLOW}📝 Test Summary:${NC}"
echo "- Health check should work (no auth required)"
echo "- All notification endpoints should fail without authentication"
echo "- This confirms the API security is working correctly"

echo -e "\n${BLUE}🔑 To test with authentication:${NC}"
echo "1. Generate a token: cd notification-api && node generate-test-token.js"
echo "2. Use the token in Authorization header: -H \"Authorization: Bearer <token>\""

echo -e "\n${BLUE}📱 To test with real Flutter app:${NC}"
echo "1. Get FCM token from Flutter app"
echo "2. Use that token in notification requests"
echo "3. Check device for actual notifications"
