export default function Deployment() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold text-red-600 mb-8">Deployment Guide</h1>
        
        <div className="space-y-12">
          {/* Flutter App Deployment */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Flutter App Deployment</h2>
            
            <div className="space-y-8">
              {/* Android Deployment */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">Android Deployment</h3>
                
                <div className="space-y-4">
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">Prerequisites</h4>
                    <ul className="list-disc list-inside space-y-1 text-gray-700">
                      <li>Google Play Console account</li>
                      <li>Signing key configured</li>
                      <li>google-services.json file in android/app/</li>
                    </ul>
                  </div>
                  
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">Build Commands</h4>
                    <div className="bg-gray-100 p-4 rounded-lg">
                      <pre className="text-sm">
{`# Build APK for testing
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build with specific target
flutter build apk --target-platform android-arm64 --release`}
                      </pre>
                    </div>
                  </div>
                  
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">Release Configuration</h4>
                    <div className="bg-gray-100 p-4 rounded-lg">
                      <p className="text-sm mb-2">Update android/app/build.gradle:</p>
                      <pre className="text-sm">
{`android {
    defaultConfig {
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}`}
                      </pre>
                    </div>
                  </div>
                </div>
              </div>

              {/* iOS Deployment */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">iOS Deployment</h3>
                
                <div className="space-y-4">
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">Prerequisites</h4>
                    <ul className="list-disc list-inside space-y-1 text-gray-700">
                      <li>Apple Developer account</li>
                      <li>Xcode with iOS SDK</li>
                      <li>GoogleService-Info.plist in ios/Runner/</li>
                      <li>Provisioning profiles configured</li>
                    </ul>
                  </div>
                  
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">Build Commands</h4>
                    <div className="bg-gray-100 p-4 rounded-lg">
                      <pre className="text-sm">
{`# Build iOS app
flutter build ios --release

# Build for specific device
flutter build ios --release --target-platform ios-arm64

# Create IPA for distribution
flutter build ipa --release`}
                      </pre>
                    </div>
                  </div>
                  
                  <div>
                    <h4 className="text-lg font-semibold text-gray-800 mb-2">App Store Configuration</h4>
                    <div className="bg-gray-100 p-4 rounded-lg">
                      <p className="text-sm mb-2">Update ios/Runner/Info.plist:</p>
                      <pre className="text-sm">
{`<key>CFBundleDisplayName</key>
<string>Blood Sea</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to find nearby blood donors.</string>`}
                      </pre>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Firebase Hosting Deployment */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firebase Hosting (Web Management)</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Setup Firebase Hosting</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <pre className="text-sm">
{`# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init hosting

# Build Next.js project
npm run build

# Deploy to Firebase
firebase deploy --only hosting`}
                  </pre>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Deployment Scripts</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <p className="text-sm mb-2">Add to package.json:</p>
                  <pre className="text-sm">
{`{
  "scripts": {
    "build": "next build",
    "deploy": "npm run build && firebase deploy --only hosting",
    "deploy:preview": "npm run build && firebase hosting:channel:deploy preview"
  }
}`}
                  </pre>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">CI/CD with GitHub Actions</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <p className="text-sm mb-2">Create .github/workflows/deploy.yml:</p>
                  <pre className="text-sm">
{`name: Deploy to Firebase Hosting

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build project
      run: npm run build
      
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: \${{ secrets.GITHUB_TOKEN }}
        firebaseServiceAccount: \${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
        projectId: your-project-id`}
                  </pre>
                </div>
              </div>
            </div>
          </section>

          {/* Firebase Backend Configuration */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firebase Backend Setup</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Initial Setup</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <pre className="text-sm">
{`# Install Firebase CLI
npm install -g firebase-tools

# Login and select project
firebase login
firebase use --add

# Initialize Firebase features
firebase init

# Select:
# - Firestore
# - Storage
# - Hosting
# - Functions (optional)`}
                  </pre>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Security Rules Deployment</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <pre className="text-sm">
{`# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy everything
firebase deploy`}
                  </pre>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Environment Configuration</h3>
                <div className="space-y-4">
                  <div>
                    <h4 className="font-semibold">Production Environment</h4>
                    <ul className="list-disc list-inside space-y-1 text-gray-700 text-sm">
                      <li>Enable Firebase App Check</li>
                      <li>Configure CORS policies</li>
                      <li>Set up monitoring and alerts</li>
                      <li>Enable Firebase Performance Monitoring</li>
                    </ul>
                  </div>
                  
                  <div>
                    <h4 className="font-semibold">Security Checklist</h4>
                    <ul className="list-disc list-inside space-y-1 text-gray-700 text-sm">
                      <li>Review and test Firestore security rules</li>
                      <li>Enable reCAPTCHA for authentication</li>
                      <li>Configure allowed domains for Auth</li>
                      <li>Set up rate limiting</li>
                      <li>Enable audit logging</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </section>

          {/* Testing & Monitoring */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Testing & Monitoring</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Flutter Testing</h3>
                <div className="bg-gray-100 p-4 rounded-lg">
                  <pre className="text-sm">
{`# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart

# Test specific file
flutter test test/auth_test.dart`}
                  </pre>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Monitoring Setup</h3>
                <ul className="space-y-2 text-gray-700">
                  <li>Firebase Crashlytics for crash reporting</li>
                  <li>Firebase Performance for app performance</li>
                  <li>Firebase Analytics for user behavior</li>
                  <li>Cloud Monitoring for backend metrics</li>
                </ul>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}