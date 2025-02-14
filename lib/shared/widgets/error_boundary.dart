// lib/shared/widgets/error_boundary.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function()? onRetry;
  final String? title;
  // Add onError callback
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.title,
    this.onError, // Add onError parameter
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  dynamic error;
  StackTrace? stackTrace;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      // Call onError callback if provided
      widget.onError?.call(errorDetails.exception, errorDetails.stack ?? StackTrace.empty);
      
      setState(() {
        hasError = true;
        error = errorDetails.exception;
        stackTrace = errorDetails.stack;
      });
      return const SizedBox.shrink();
    };
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title ?? 'Something went wrong',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (error != null)
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (stackTrace != null && kDebugMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      stackTrace.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 16),
                if (widget.onRetry != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        hasError = false;
                        error = null;
                        stackTrace = null;
                      });
                      widget.onRetry?.call();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
