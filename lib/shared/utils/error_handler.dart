// lib/shared/utils/error_handler.dart
import 'package:flutter/material.dart';

class ErrorHandler {
  static void logError(Object error, StackTrace stackTrace) {
    debugPrint('Error: $error');
    debugPrint('Stack Trace: $stackTrace');
  }

  static void showErrorDialog(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Debug Error Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 8),
              Text(
                'Stack Trace:\n$stackTrace',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
