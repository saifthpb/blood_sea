export default function ApiDocs() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl font-bold text-red-600 mb-8">API Documentation</h1>
        
        <div className="space-y-12">
          {/* Firebase Collections */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firestore Collections</h2>
            
            <div className="space-y-8">
              {/* Users Collection */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">users</h3>
                <p className="text-gray-600 mb-4">Stores user profile information for both donors and clients.</p>
                
                <div className="bg-gray-100 p-4 rounded-lg">
                  <h4 className="font-semibold mb-2">Document Structure:</h4>
                  <pre className="text-sm overflow-x-auto">
{`{
  "uid": "string",           // Firebase Auth UID
  "email": "string",         // User email
  "name": "string",          // Full name
  "phone": "string",         // Phone number
  "userType": "donor|client", // User role
  "bloodGroup": "string",    // Blood group (for donors)
  "location": {              // User location
    "address": "string",
    "city": "string",
    "state": "string",
    "coordinates": {
      "latitude": "number",
      "longitude": "number"
    }
  },
  "profileImage": "string",  // Storage URL
  "isAvailable": "boolean",  // For donors
  "lastSeen": "timestamp",   // Last active time
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}`}
                  </pre>
                </div>
              </div>

              {/* Donors Collection */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">donors</h3>
                <p className="text-gray-600 mb-4">Optimized collection for donor search and filtering.</p>
                
                <div className="bg-gray-100 p-4 rounded-lg">
                  <h4 className="font-semibold mb-2">Document Structure:</h4>
                  <pre className="text-sm overflow-x-auto">
{`{
  "uid": "string",           // Reference to users collection
  "name": "string",
  "bloodGroup": "string",    // A+, A-, B+, B-, AB+, AB-, O+, O-
  "phone": "string",
  "location": {
    "city": "string",
    "state": "string",
    "coordinates": "geopoint"
  },
  "isAvailable": "boolean",
  "lastDonation": "timestamp",
  "profileImage": "string",
  "rating": "number",        // Average rating
  "totalDonations": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}`}
                  </pre>
                </div>
              </div>

              {/* Notifications Collection */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">notifications</h3>
                <p className="text-gray-600 mb-4">Stores notification data for users.</p>
                
                <div className="bg-gray-100 p-4 rounded-lg">
                  <h4 className="font-semibold mb-2">Document Structure:</h4>
                  <pre className="text-sm overflow-x-auto">
{`{
  "id": "string",
  "recipientId": "string",   // User UID
  "senderId": "string",      // Sender UID (optional)
  "type": "string",          // blood_request, system, etc.
  "title": "string",
  "message": "string",
  "data": {                  // Additional data
    "bloodGroup": "string",
    "location": "string",
    "urgency": "string"
  },
  "isRead": "boolean",
  "createdAt": "timestamp"
}`}
                  </pre>
                </div>
              </div>

              {/* Blood Requests Collection */}
              <div>
                <h3 className="text-2xl font-semibold text-red-600 mb-4">bloodRequests</h3>
                <p className="text-gray-600 mb-4">Tracks blood donation requests.</p>
                
                <div className="bg-gray-100 p-4 rounded-lg">
                  <h4 className="font-semibold mb-2">Document Structure:</h4>
                  <pre className="text-sm overflow-x-auto">
{`{
  "id": "string",
  "requesterId": "string",   // Client UID
  "bloodGroup": "string",
  "urgency": "low|medium|high|critical",
  "location": {
    "hospital": "string",
    "address": "string",
    "city": "string",
    "coordinates": "geopoint"
  },
  "contactInfo": {
    "name": "string",
    "phone": "string",
    "email": "string"
  },
  "additionalInfo": "string",
  "status": "active|fulfilled|expired",
  "respondedDonors": ["string"], // Array of donor UIDs
  "createdAt": "timestamp",
  "expiresAt": "timestamp"
}`}
                  </pre>
                </div>
              </div>
            </div>
          </section>

          {/* Firestore Indexes */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firestore Indexes</h2>
            
            <div className="bg-gray-100 p-4 rounded-lg">
              <h4 className="font-semibold mb-2">Required Composite Indexes:</h4>
              <pre className="text-sm overflow-x-auto">
{`// Donor search by blood group and availability
donors: bloodGroup (Ascending), isAvailable (Ascending)

// Donor search by location and blood group
donors: location.city (Ascending), bloodGroup (Ascending), isAvailable (Ascending)

// Notifications by recipient and timestamp
notifications: recipientId (Ascending), createdAt (Descending)

// Blood requests by status and timestamp
bloodRequests: status (Ascending), createdAt (Descending)

// Blood requests by blood group and urgency
bloodRequests: bloodGroup (Ascending), urgency (Descending), status (Ascending)`}
              </pre>
            </div>
          </section>

          {/* Firebase Cloud Functions */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Cloud Functions (Potential)</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Notification Triggers</h3>
                <ul className="space-y-2 text-gray-700">
                  <li><strong>onBloodRequestCreate:</strong> Send notifications to matching donors</li>
                  <li><strong>onUserStatusChange:</strong> Update donor availability</li>
                  <li><strong>onDonationComplete:</strong> Update donor statistics</li>
                </ul>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Scheduled Functions</h3>
                <ul className="space-y-2 text-gray-700">
                  <li><strong>cleanupExpiredRequests:</strong> Remove old blood requests</li>
                  <li><strong>updateDonorAvailability:</strong> Reset availability based on last donation</li>
                  <li><strong>sendReminderNotifications:</strong> Remind users to update status</li>
                </ul>
              </div>
            </div>
          </section>

          {/* FCM Integration */}
          <section className="bg-white rounded-lg shadow-lg p-8">
            <h2 className="text-3xl font-semibold text-gray-800 mb-6">Firebase Cloud Messaging</h2>
            
            <div className="space-y-6">
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Message Types</h3>
                <div className="space-y-4">
                  <div className="bg-gray-100 p-4 rounded-lg">
                    <h4 className="font-semibold mb-2">Blood Request Notification:</h4>
                    <pre className="text-sm">
{`{
  "notification": {
    "title": "Urgent Blood Request",
    "body": "Someone needs B+ blood in your area"
  },
  "data": {
    "type": "blood_request",
    "requestId": "request_id",
    "bloodGroup": "B+",
    "location": "City Hospital"
  }
}`}
                    </pre>
                  </div>
                  
                  <div className="bg-gray-100 p-4 rounded-lg">
                    <h4 className="font-semibold mb-2">System Notification:</h4>
                    <pre className="text-sm">
{`{
  "notification": {
    "title": "Profile Update Required",
    "body": "Please update your availability status"
  },
  "data": {
    "type": "system",
    "action": "update_profile"
  }
}`}
                    </pre>
                  </div>
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-3">Token Management</h3>
                <ul className="space-y-2 text-gray-700">
                  <li>FCM tokens stored in user documents</li>
                  <li>Token refresh handled automatically</li>
                  <li>Multiple device support per user</li>
                  <li>Topic subscriptions for broadcast messages</li>
                </ul>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}