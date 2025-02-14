import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/notification_bloc.dart';
import '../models/notification_model.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationBloc()..add(LoadNotifications()),
      child: Scaffold(
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NotificationBloc>()
                          .add(LoadNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.notifications.isEmpty) {
                return const Center(
                  child: Text('No notifications'),
                );
              }

              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onDismiss: () => _handleNotificationDismiss(
                      context,
                      notification,
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Mark as read
    context
        .read<NotificationBloc>()
        .add(MarkAsRead(notification.id));

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
    context
        .read<NotificationBloc>()
        .add(DeleteNotification(notification.id));
  }
}
