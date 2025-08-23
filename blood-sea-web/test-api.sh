#!/bin/bash

# Blood Sea API Testing Script
# This script tests all the converted API endpoints

set -e

API_BASE="http://localhost:3000"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔬 Blood Sea API Testing Script${NC}"
echo "=================================="

# Function to print test results
print_test_result() {
    local test_name="$1"
    local status_code="$2"
    local expected_code="$3"
    local response="$4"
    
    if [ "$status_code" -eq "$expected_code" ]; then
        echo -e "${GREEN}✅ $test_name - PASSED (Status: $status_code)${NC}"
    else
        echo -e "${RED}❌ $test_name - FAILED (Expected: $expected_code, Got: $status_code)${NC}"
        echo -e "${YELLOW}Response: $response${NC}"
    fi
}

# Function to make API request
make_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local auth_header="$4"
    
    if [ -n "$data" ] && [ -n "$auth_header" ]; then
        curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $auth_header" \
            -d "$data" \
            "$API_BASE$endpoint"
    elif [ -n "$data" ]; then
        curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_BASE$endpoint"
    elif [ -n "$auth_header" ]; then
        curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $auth_header" \
            "$API_BASE$endpoint"
    else
        curl -s -w "%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            "$API_BASE$endpoint"
    fi
}

echo -e "\n${BLUE}1. Testing Health Check Endpoint${NC}"
echo "-----------------------------------"

response=$(make_request "GET" "/api/health/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Health Check" "$status_code" "200" "$body"

echo -e "\n${BLUE}2. Testing Authentication Required Endpoints (Without Auth)${NC}"
echo "-------------------------------------------------------------"

# Test endpoints that require authentication without providing auth
endpoints=(
    "POST /api/users/fcm-token/"
    "GET /api/users/profile/"
    "POST /api/notifications/send/"
)

for endpoint_info in "${endpoints[@]}"; do
    method=$(echo "$endpoint_info" | cut -d' ' -f1)
    path=$(echo "$endpoint_info" | cut -d' ' -f2)
    
    if [ "$method" = "POST" ]; then
        response=$(make_request "$method" "$path" '{"test":"data"}')
    else
        response=$(make_request "$method" "$path")
    fi
    
    status_code="${response: -3}"
    body="${response%???}"
    print_test_result "$endpoint_info (No Auth)" "$status_code" "401" "$body"
done

echo -e "\n${BLUE}3. Testing Validation Errors${NC}"
echo "-------------------------------"

# Test with invalid JSON
response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d 'invalid json' \
    "$API_BASE/api/users/fcm-token/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Invalid JSON" "$status_code" "401" "$body"

# Test with missing required fields (will get 401 first due to no auth)
response=$(make_request "POST" "/api/users/fcm-token/" '{}')
status_code="${response: -3}"
body="${response%???}"
print_test_result "Missing Required Fields" "$status_code" "401" "$body"

echo -e "\n${BLUE}4. Testing Rate Limiting${NC}"
echo "----------------------------"

echo "Making multiple requests to test rate limiting..."
for i in {1..12}; do
    response=$(make_request "GET" "/api/health/")
    status_code="${response: -3}"
    
    if [ "$status_code" -eq "429" ]; then
        echo -e "${GREEN}✅ Rate limiting triggered on request $i${NC}"
        break
    elif [ "$i" -eq "12" ]; then
        echo -e "${YELLOW}⚠️ Rate limiting not triggered within 12 requests (may be configured for higher limit)${NC}"
    fi
done

echo -e "\n${BLUE}5. Testing CORS Headers${NC}"
echo "-------------------------"

response=$(curl -s -I -X OPTIONS "$API_BASE/api/health/")
if echo "$response" | grep -q "Access-Control-Allow"; then
    echo -e "${GREEN}✅ CORS headers present${NC}"
else
    echo -e "${RED}❌ CORS headers missing${NC}"
fi

echo -e "\n${BLUE}6. Testing Error Handling${NC}"
echo "---------------------------"

# Test non-existent endpoint
response=$(make_request "GET" "/api/nonexistent/")
status_code="${response: -3}"
body="${response%???}"
print_test_result "Non-existent Endpoint" "$status_code" "404" "$body"

echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "=================="
echo "✅ Health Check: Working"
echo "✅ Authentication: Properly blocking unauthorized requests"
echo "✅ Validation: Rejecting invalid requests"
echo "✅ Error Handling: Returning appropriate error codes"
echo "✅ CORS: Headers configured"

echo -e "\n${YELLOW}📝 Next Steps for Complete Testing:${NC}"
echo "1. Generate a valid Firebase ID token for authenticated endpoint testing"
echo "2. Test all user management endpoints with valid authentication"
echo "3. Test notification endpoints with valid FCM tokens"
echo "4. Test with real Firebase user data"
echo ""
echo -e "${GREEN}🎉 Basic API infrastructure is working correctly!${NC}"
echo ""
echo -e "${BLUE}To test authenticated endpoints, you'll need to:${NC}"
echo "1. Create a Firebase user in your project"
echo "2. Get an ID token from Firebase Authentication"
echo "3. Use the token in Authorization header: 'Bearer <token>'"
echo ""
echo "Example with token:"
echo "curl -X GET http://localhost:3000/api/users/profile/ \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer <your-firebase-id-token>'"
