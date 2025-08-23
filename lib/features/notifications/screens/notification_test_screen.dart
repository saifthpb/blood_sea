import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service_enhanced.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _donorIdController = TextEditingController();
  final _bloodTypeController = TextEditingController(text: 'A+');
  final _locationController = TextEditingController(text: 'Test Hospital, Test City');
  final _messageController = TextEditingController(text: 'This is a test blood request');
  
  String _selectedUrgency = 'urgent';
  bool _isLoading = false;
  String _lastResult = '';
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _getCurrentToken();
  }

  Future<void> _getCurrentToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        setState(() {
          _currentToken = token;
        });
      }
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Sending test notification...';
    });

    try {
      final result = await NotificationServiceEnhanced.sendTestNotification();
      setState(() {
        _lastResult = result 
            ? '✅ Test notification sent successfully!' 
            : '❌ Failed to send test notification';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendBloodRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastResult = 'Sending blood request...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _lastResult = '❌ No authenticated user found';
        });
        return;
      }

      final result = await NotificationServiceEnhanced.sendBloodRequestNotification(
        donorId: _donorIdController.text.trim(),
        requesterId: user.uid,
        requesterName: user.displayName ?? 'Test User',
        requesterPhone: user.phoneNumber ?? '+1234567890',
        bloodType: _bloodTypeController.text.trim(),
        location: _locationController.text.trim(),
        urgency: _selectedUrgency,
        requiredDate: DateTime.now().add(const Duration(days: 1)),
        additionalMessage: _messageController.text.trim(),
      );

      setState(() {
        _lastResult = result 
            ? '✅ Blood request sent successfully!' 
            : '❌ Failed to send blood request';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Updating notification settings...';
    });

    try {
      final result = await NotificationServiceEnhanced.updateNotificationSettings(
        bloodRequests: true,
        emergencyRequests: true,
        generalAnnouncements: false,
        soundEnabled: true,
        vibrationEnabled: true,
      );

      setState(() {
        _lastResult = result 
            ? '✅ Notification settings updated!' 
            : '❌ Failed to update settings';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getNotifications() async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Fetching notifications...';
    });

    try {
      final notifications = await NotificationServiceEnhanced.getUserNotifications(
        limit: 10,
        unreadOnly: false,
      );

      setState(() {
        _lastResult = '✅ Found ${notifications.length} notifications';
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToken() {
    if (_currentToken != null) {
      Clipboard.setData(ClipboardData(text: _currentToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Testing'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current User Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current User',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('UID: ${FirebaseAuth.instance.currentUser?.uid ?? 'Not logged in'}'),
                      Text('Email: ${FirebaseAuth.instance.currentUser?.email ?? 'No email'}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Token: ${_currentToken?.substring(0, 50) ?? 'No token'}...',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          IconButton(
                            onPressed: _copyToken,
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy token',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Quick Tests
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Tests',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendTestNotification,
                        icon: const Icon(Icons.notifications),
                        label: const Text('Send Test Notification'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateNotificationSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Update Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getNotifications,
                        icon: const Icon(Icons.list),
                        label: const Text('Get Notifications'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Blood Request Test
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Blood Request Test',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _donorIdController,
                        decoration: const InputDecoration(
                          labelText: 'Donor ID',
                          hintText: 'Enter donor user ID',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter donor ID';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _bloodTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Blood Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter blood type';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedUrgency,
                        decoration: const InputDecoration(
                          labelText: 'Urgency',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'normal', child: Text('Normal')),
                          DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                          DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedUrgency = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Message',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendBloodRequest,
                        icon: const Icon(Icons.bloodtype),
                        label: const Text('Send Blood Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Result Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Result',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Processing...'),
                          ],
                        )
                      else
                        Text(
                          _lastResult.isEmpty ? 'No tests run yet' : _lastResult,
                          style: TextStyle(
                            color: _lastResult.startsWith('✅') 
                                ? Colors.green 
                                : _lastResult.startsWith('❌') 
                                    ? Colors.red 
                                    : Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instructions
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Testing Instructions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. Make sure the API server is running on localhost:3000'),
                      const Text('2. Update the API URL in notification_service_enhanced.dart'),
                      const Text('3. Use a valid donor ID for blood request tests'),
                      const Text('4. Check the API logs for detailed information'),
                      const Text('5. Copy your Firebase token for manual API testing'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _donorIdController.dispose();
    _bloodTypeController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
