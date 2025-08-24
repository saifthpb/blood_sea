# 🚀 Deploy Blood Sea API with Next.js (Unified Approach)

## Option 1: Vercel Deployment (Recommended)

### Step 1: Restore API Routes to Next.js
```bash
cd blood-sea-web

# Remove static export from next.config.ts
# Change from:
# output: 'export'
# To: (remove the line entirely)
```

### Step 2: Add API Routes Back
```bash
# Copy API routes from blood-sea-api to src/app/api/
mkdir -p src/app/api/notifications
# Copy the route files we created earlier
```

### Step 3: Add Environment Variables
```bash
# Create .env.local with Firebase credentials
FIREBASE_PROJECT_ID=blood-sea-57816
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-u37i4@blood-sea-57816.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
```

### Step 4: Deploy to Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard
# Your app will be at: https://blood-sea-web.vercel.app
```

## Option 2: Keep Current Setup (Recommended)

### Why Current Setup is Better:
1. **Admin Panel**: FREE on Firebase Hosting
2. **API**: Deploy anywhere (Railway, Render, etc.)
3. **Performance**: Static admin panel loads instantly
4. **Cost**: Much cheaper long-term
5. **Flexibility**: Can change API hosting without affecting admin

### Current URLs:
- Admin Panel: https://blood-sea-57816.web.app (FREE)
- API: Deploy to Railway/Render (~$0-5/month)

## 💡 My Strong Recommendation

**Keep the current separated architecture because:**

1. **Cost**: Firebase static hosting = FREE forever
2. **Performance**: Static sites are faster
3. **Reliability**: Admin panel works even if API is down
4. **Scalability**: Can scale API independently
5. **Professional**: Microservices architecture is industry standard

**Just deploy the standalone API to Railway - it's the best approach!**
