// lib/features/notifications/bloc/notification_bloc.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification_model.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _notificationSubscription;

  NotificationBloc() : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationReceived>(_onNotificationReceived);
    on<MarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(NotificationLoading());

      final user = _auth.currentUser;
      if (user == null) {
        emit(const NotificationError('User not authenticated') as NotificationState);
        return;
      }

      print('Loading notifications for user: ${user.uid}');

      // Cancel existing subscription if any
      await _notificationSubscription?.cancel();

      // Create new subscription
      _notificationSubscription = _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          if (!isClosed) {
            add(NotificationReceived(snapshot));
          }
        },
        onError: (error) {
          print('Error listening to notifications: $error');
          if (!isClosed) {
            add(NotificationEventError(error.toString()));
          }
        },
      );
    } catch (e) {
      print('Error in _onLoadNotifications: $e');
      emit(NotificationEventError(e.toString()) as NotificationState);
    }
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = event.snapshot.docs.map((doc) {
        return NotificationModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      emit(NotificationLoaded(notifications));
    } catch (e) {
      print('Error in _onNotificationReceived: $e');
      emit(NotificationError(e.toString()) as NotificationState);
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
      print('Error marking notification as read: $e');
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _notificationSubscription?.cancel();
    return super.close();
  }
}


abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class NotificationReceived extends NotificationEvent {
  final QuerySnapshot snapshot;

  const NotificationReceived(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}

class NotificationEventError extends NotificationEvent {
  final String message;

  const NotificationEventError(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkAsRead extends NotificationEvent {
  final String notificationId;

  const MarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}


abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationLoaded(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
