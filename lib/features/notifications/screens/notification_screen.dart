import 'package:blood_sea/shared/widgets/error_boundary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../shared/utils/error_handler.dart';
import '../bloc/notification_bloc.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
                    child: Text('No notifications'),
                  );
                }

                return ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = state.notifications[index];
                    return ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: notification.isRead
                          ? null
                          : const CircleAvatar(
                              radius: 4,
                              backgroundColor: Colors.red,
                            ),
                      onTap: () {
                        context
                            .read<NotificationBloc>()
                            .add(MarkAsRead(notification.id));
                      },
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
}
