export default function Architecture() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold text-red-600 mb-8">System Architecture</h1>
        
        <div className="space-y-12">
          {/* Flutter App Architecture */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Flutter App Architecture</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">State Management</h3>
                <ul className="space-y-2 text-gray-700">
                  <li><strong>BLoC Pattern:</strong> flutter_bloc for state management</li>
                  <li><strong>AuthBloc:</strong> Handles authentication state</li>
                  <li><strong>DonorBloc:</strong> Manages donor data and operations</li>
                  <li><strong>NotificationBloc:</strong> Handles notification state</li>
                  <li><strong>ProfileBloc:</strong> User profile management</li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Navigation</h3>
                <ul className="space-y-2 text-gray-700">
                  <li><strong>GoRouter:</strong> Declarative routing</li>
                  <li><strong>Protected Routes:</strong> Authentication required</li>
                  <li><strong>Shell Routes:</strong> Bottom navigation structure</li>
                  <li><strong>Configuration:</strong> lib/config/router.dart</li>
                </ul>
              </div>
            </div>
            
            <div className="mt-8">
              <h3 className="text-xl font-semibold text-red-600 mb-4">Project Structure</h3>
              <pre className="bg-gray-100 p-4 rounded-lg overflow-x-auto text-sm">
{`lib/
├── blocs/                 # Global BLoC observer
├── config/               # App configuration
│   ├── constants.dart
│   ├── router.dart
│   └── theme.dart
├── core/                 # Core utilities
│   ├── di/              # Dependency injection
│   └── navigation/      # Navigation service
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── donors/         # Donor management
│   ├── notifications/  # Notification system
│   ├── profile/        # User profile
│   └── ...
├── services/           # Global services
├── shared/            # Shared components
│   ├── utils/
│   └── widgets/
└── main.dart`}
              </pre>
            </div>
          </section>

          {/* Firebase Backend */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firebase Backend</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Services Used</h3>
                <ul className="space-y-3 text-gray-700">
                  <li>
                    <strong>Firebase Auth:</strong>
                    <span className="block text-sm text-gray-600">User authentication and authorization</span>
                  </li>
                  <li>
                    <strong>Cloud Firestore:</strong>
                    <span className="block text-sm text-gray-600">NoSQL database for user data, donors, notifications</span>
                  </li>
                  <li>
                    <strong>Firebase Storage:</strong>
                    <span className="block text-sm text-gray-600">Profile image storage</span>
                  </li>
                  <li>
                    <strong>Firebase Cloud Messaging:</strong>
                    <span className="block text-sm text-gray-600">Push notifications</span>
                  </li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Data Models</h3>
                <ul className="space-y-3 text-gray-700">
                  <li>
                    <strong>User Model:</strong>
                    <span className="block text-sm text-gray-600">User types: &apos;donor&apos; and &apos;client&apos;</span>
                  </li>
                  <li>
                    <strong>Donor Model:</strong>
                    <span className="block text-sm text-gray-600">Blood group, location, availability</span>
                  </li>
                  <li>
                    <strong>Notification Model:</strong>
                    <span className="block text-sm text-gray-600">Blood requests, system alerts</span>
                  </li>
                </ul>
              </div>
            </div>
          </section>

          {/* Security & Rules */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Security Implementation</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Firestore Security Rules</h3>
                <pre className="bg-gray-100 p-4 rounded-lg overflow-x-auto text-sm">
{`rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Donors can be read by authenticated users
    match /donors/{donorId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == donorId;
    }
  }
}`}
                </pre>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Authentication Flow</h3>
                <ol className="list-decimal list-inside space-y-2 text-gray-700">
                  <li>User registers as either donor or client</li>
                  <li>Email verification (optional)</li>
                  <li>Profile completion with additional details</li>
                  <li>JWT token management for authenticated requests</li>
                  <li>Automatic session management via Firebase SDK</li>
                </ol>
              </div>
            </div>
          </section>

          {/* Performance & Optimization */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Performance Optimization</h2>
            
            <div className="grid md:grid-cols-2 gap-8">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Flutter Optimizations</h3>
                <ul className="space-y-2 text-gray-700">
                  <li>BLoC pattern for efficient state management</li>
                  <li>Lazy loading of donor lists</li>
                  <li>Image caching and optimization</li>
                  <li>Offline support with local storage</li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-4">Firebase Optimizations</h3>
                <ul className="space-y-2 text-gray-700">
                  <li>Composite indexes for efficient queries</li>
                  <li>Pagination for large datasets</li>
                  <li>Real-time listeners optimization</li>
                  <li>FCM token management</li>
                </ul>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}