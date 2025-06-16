import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../shared/utils/error_handler.dart';
import '../bloc/notification_bloc.dart';
import '../models/notification_type.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      title: 'Error Loading Notifications',
      onError: (error, stackTrace, context) {
        ErrorHandler.logError(error, stackTrace);
        if (kDebugMode) {
          final navigatorContext = NavigationService.context;
          if (navigatorContext != null && navigatorContext.mounted) {
            ErrorHandler.showErrorDialog(navigatorContext, error, stackTrace);
          }
        }
      },
      onRetry: () {
        final navigatorContext = NavigationService.context;
        if (navigatorContext != null && navigatorContext.mounted) {
          navigatorContext.read<NotificationBloc>().add(LoadNotifications());
        }
      },
      child: BlocProvider(
        create: (context) => NotificationBloc()..add(LoadNotifications()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: Colors.redAccent,
          ),
          body: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is NotificationIndexing) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Creating database index, please wait...'),
                    ],
                  ),
                );
              }

              if (state is NotificationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<NotificationBloc>()
                              .add(LoadNotifications());
                        },
                        child: const Text('Retry'),
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
                        Icon(Icons.notifications_off_outlined, 
                             size: 64, 
                             color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notifications yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: state.notifications.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return InkWell(
                      onTap: () {
                        if (!notification.isRead) {
                          context
                              .read<NotificationBloc>()
                              .add(MarkAsRead(notification.id));
                        }
                        // Handle notification tap based on type
                        // You can navigate to different screens based on notification type
                      },
                      child: Container(
                        color: notification.isRead 
                            ? null 
                            : Colors.red.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sender's profile picture
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: notification.senderImage!.isNotEmpty
                                    ? NetworkImage(notification.senderImage!)
                                    : null,
                                child: notification.senderImage!.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: 
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          notification.senderName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          _getTimeAgo(notification.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Notification type indicator
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(notification.type)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        NotificationType.fromValue(notification.type).displayName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getTypeColor(notification.type),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    final notificationType = NotificationType.fromValue(type);
    return NotificationType.getColor(notificationType);
  }
}
