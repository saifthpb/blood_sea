import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GetTokenScreen extends StatefulWidget {
  const GetTokenScreen({Key? key}) : super(key: key);

  @override
  State<GetTokenScreen> createState() => _GetTokenScreenState();
}

class _GetTokenScreenState extends State<GetTokenScreen> {
  String? _idToken;
  String? _userInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserInfo();
  }

  Future<void> _getCurrentUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userInfo = '''
Current User:
• UID: ${user.uid}
• Email: ${user.email ?? 'No email'}
• Display Name: ${user.displayName ?? 'No name'}
• Email Verified: ${user.emailVerified}
• Phone: ${user.phoneNumber ?? 'No phone'}
''';
      });
    } else {
      setState(() {
        _userInfo = 'No user is currently signed in';
      });
    }
  }

  Future<void> _getIdToken() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user is signed in. Please log in first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get the ID token
      final idToken = await user.getIdToken(true); // true = force refresh
      
      setState(() {
        _idToken = idToken;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ID Token retrieved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error getting ID token: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToken() {
    if (_idToken != null) {
      Clipboard.setData(ClipboardData(text: _idToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Token copied to clipboard!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _copyExportCommand() {
    if (_idToken != null) {
      final command = 'export FIREBASE_TOKEN="$_idToken"';
      Clipboard.setData(ClipboardData(text: command));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Export command copied to clipboard!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Firebase ID Token'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userInfo ?? 'Loading...',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Get Token Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getIdToken,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.security),
              label: Text(_isLoading ? 'Getting Token...' : 'Get ID Token'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Token Display Card
            if (_idToken != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Firebase ID Token',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _copyToken,
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy Token',
                              ),
                              IconButton(
                                onPressed: _copyExportCommand,
                                icon: const Icon(Icons.terminal),
                                tooltip: 'Copy Export Command',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: SelectableText(
                          _idToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Token Length: ${_idToken!.length} characters',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Instructions Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How to Use This Token',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. Copy the token above'),
                      const Text('2. Open your terminal'),
                      const Text('3. Run this command:'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SelectableText(
                          'export FIREBASE_TOKEN="${_idToken!.substring(0, 50)}..."',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('4. Run your API tests:'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const SelectableText(
                          './test-local.sh',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Important Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• ID tokens expire after 1 hour'),
                    const Text('• Get a fresh token if API calls fail'),
                    const Text('• This token proves you are authenticated'),
                    const Text('• Never share tokens publicly'),
                    const Text('• Use this token for API testing only'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
