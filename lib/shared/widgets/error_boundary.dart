import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Function()? onRetry;
  final String? title;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.title,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  dynamic error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      setState(() {
        hasError = true;
        error = errorDetails.exception;
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
                const SizedBox(height: 16),
                if (widget.onRetry != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        hasError = false;
                        error = null;
                      });
                      widget.onRetry?.call();
                    },
                    child: const Text('Retry'),
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
