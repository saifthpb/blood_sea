import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationUsageExample extends StatelessWidget {
  const NotificationUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _sendBloodRequestNotification(),
              child: const Text('Send Blood Request Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _sendGeneralNotification(),
              child: const Text('Send General Notification'),
            ),
            const SizedBox(height: 32),
            const Text('User Notifications:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: _buildNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }

  // Example: Send blood request notification
  Future<void> _sendBloodRequestNotification() async {
    bool success = await NotificationService.sendBloodRequestNotification(
      donorId: 'donor_user_id_123', // Replace with actual donor ID
      requestId: 'request_id_456', // Replace with actual request ID
      requesterId: 'requester_user_id_789', // Replace with actual requester ID
      bloodType: 'O+',
      location: 'Dhaka Medical College Hospital',
      urgency: 'urgent',
    );

    print('Blood request notification sent: $success');
  }

  // Example: Send general notification
  Future<void> _sendGeneralNotification() async {
    bool success = await NotificationService.sendGeneralNotification(
      userId: 'user_id_123', // Replace with actual user ID
      title: 'Welcome to Blood Sea',
      message: 'Thank you for joining our blood donation community!',
      type: 'welcome',
      additionalData: {
        'action': 'welcome_screen',
      },
    );

    print('General notification sent: $success');
  }

  // Build notifications list
  Widget _buildNotificationsList() {
    // Replace 'current_user_id' with actual current user ID
    return StreamBuilder(
      stream: NotificationService.getUserNotifications('current_user_id'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var notification = snapshot.data!.docs[index];
            var data = notification.data() as Map<String, dynamic>;

            return Card(
              child: ListTile(
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['message'] ?? 'No Message'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!data['isRead'])
                      const Icon(Icons.circle, color: Colors.red, size: 12),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => NotificationService.markNotificationAsRead(notification.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => NotificationService.deleteNotification(notification.id),
                    ),
                  ],
                ),
                onTap: () {
                  // Handle notification tap
                  if (data['type'] == 'blood_request') {
                    // Navigate to blood request details
                    print('Navigate to blood request: ${data['requestId']}');
                  }
                  
                  // Mark as read
                  NotificationService.markNotificationAsRead(notification.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}
