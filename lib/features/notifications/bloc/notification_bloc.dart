import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        emit(const NotificationError('User not authenticated'));
        return;
      }

      // Listen to notifications in real-time
      _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          final notifications = snapshot.docs
              .map((doc) => NotificationModel.fromMap(
                    doc.data(),
                    doc.id,
                  ))
              .toList();

          final unreadCount =
              notifications.where((notification) => !notification.isRead).length;

          emit(NotificationLoaded(
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        },
        onError: (error) {
          emit(NotificationError(error.toString()));
        },
      );
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(event.notificationId)
          .update({'isRead': true});
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(event.notificationId)
          .delete();
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}
