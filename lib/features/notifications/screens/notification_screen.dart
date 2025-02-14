import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/utils/error_handler.dart';
import '../bloc/notification_bloc.dart';
import '../models/notification_model.dart';
import '../utils/notification_service.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
        onError: (error, stackTrace) {
          ErrorHandler.logError(error, stackTrace);
          ErrorHandler.showErrorDialog(context, error, stackTrace);
        },
        onRetry: () {
          // Reload notifications
          context.read<NotificationBloc>().add(LoadNotifications());
        },
        child: BlocProvider(
          create: (context) => NotificationBloc()..add(LoadNotifications()),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              actions: [
                // Add test button in debug mode
                if (kDebugMode)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      NotificationService().createTestNotification();
                    },
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(LoadNotifications());
              },
              child: BlocConsumer<NotificationBloc, NotificationState>(
                listener: (context, state) {
                  if (state is NotificationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        action: SnackBarAction(
                          label: 'Retry',
                          onPressed: () {
                            context
                                .read<NotificationBloc>()
                                .add(LoadNotifications());
                          },
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  debugPrint('Current notification state: $state');
                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is NotificationError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<NotificationBloc>()
                                  .add(LoadNotifications());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is NotificationLoaded) {
                    if (state.notifications.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () =>
                              _handleNotificationTap(context, notification),
                          onDismiss: () =>
                              _handleNotificationDismiss(context, notification),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ));
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark as read
    context.read<NotificationBloc>().add(MarkAsRead(notification.id));

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.bloodRequest:
        context.push(
          '/blood-request/${notification.additionalData?['requestId']}',
          extra: notification,
        );
        break;
      case NotificationType.message:
        context.push(
          '/chat/${notification.senderId}',
          extra: notification,
        );
        break;
      default:
        // Handle other notification types
        break;
    }
  }

  void _handleNotificationDismiss(
    BuildContext context,
    NotificationModel notification,
  ) {
    context.read<NotificationBloc>().add(DeleteNotification(notification.id));
  }
}
