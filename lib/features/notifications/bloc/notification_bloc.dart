import 'dart:async';

import 'package:flutter/foundation.dart';
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


class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<DeleteNotification>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(const NotificationError('User not authenticated'));
        return;
      }

      // Cancel existing subscription if any
      await _notificationSubscription?.cancel();

      // Create the query
      final Query query = _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .limit(50); // Add limit for performance

      // Start listening to notifications
      _notificationSubscription = query.snapshots().listen(
        (snapshot) {
          try {
            final notifications = snapshot.docs.map((doc) {
              try {
                return NotificationModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              } catch (e) {
                if (kDebugMode) {
                  print('Error parsing notification: $e');
                  print('Document data: ${doc.data()}');
                }
                return null;
              }
            }).where((notification) => notification != null).toList();

            final unreadCount = notifications
                .where((notification) => !notification!.isRead)
                .length;

            emit(NotificationLoaded(
              notifications: notifications.cast<NotificationModel>(),
              unreadCount: unreadCount,
            ));
          } catch (e) {
            if (kDebugMode) {
              print('Error processing notifications: $e');
            }
            emit(NotificationError(e.toString()));
          }
        },
        onError: (error) {
          if (kDebugMode) {
            print('Error listening to notifications: $error');
          }
          emit(NotificationError(error.toString()));
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in LoadNotifications: $e');
      }
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
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
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
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}