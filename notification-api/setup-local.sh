#!/bin/bash

# Blood Sea Notification API - Local Development Setup
echo "🩸 Setting up Blood Sea Notification API for local development..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 16+ first.${NC}"
    echo "Visit: https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo -e "${RED}❌ Node.js version 16+ required. Current version: $(node -v)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js version: $(node -v)${NC}"

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies installed successfully${NC}"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚙️ Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}📝 Please edit .env file with your Firebase credentials${NC}"
    echo -e "${YELLOW}   You can find these in Firebase Console > Project Settings > Service Accounts${NC}"
else
    echo -e "${GREEN}✅ .env file already exists${NC}"
fi

# Create logs directory
mkdir -p logs
echo -e "${GREEN}✅ Created logs directory${NC}"

# Check if Firebase credentials are configured
if grep -q "your_private_key_id" .env; then
    echo -e "${YELLOW}⚠️  Firebase credentials not configured in .env file${NC}"
    echo -e "${YELLOW}   Please update the following in .env:${NC}"
    echo -e "${YELLOW}   - FIREBASE_PROJECT_ID${NC}"
    echo -e "${YELLOW}   - FIREBASE_PRIVATE_KEY_ID${NC}"
    echo -e "${YELLOW}   - FIREBASE_PRIVATE_KEY${NC}"
    echo -e "${YELLOW}   - FIREBASE_CLIENT_EMAIL${NC}"
    echo -e "${YELLOW}   - FIREBASE_CLIENT_ID${NC}"
    echo -e "${YELLOW}   - FIREBASE_CLIENT_CERT_URL${NC}"
fi

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo -e "   1. Configure Firebase credentials in .env file"
echo -e "   2. Run: ${GREEN}npm run dev${NC} to start development server"
echo -e "   3. Test API: ${GREEN}curl http://localhost:3000/health${NC}"
echo -e "   4. View logs in ./logs/ directory"
echo ""
echo -e "${BLUE}🔗 Useful commands:${NC}"
echo -e "   • Start development: ${GREEN}npm run dev${NC}"
echo -e "   • Start production: ${GREEN}npm start${NC}"
echo -e "   • Run tests: ${GREEN}npm test${NC}"
echo -e "   • View logs: ${GREEN}tail -f logs/combined.log${NC}"
