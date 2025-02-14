import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final User? user;
  AuthStateChanged(this.user);
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User firebaseUser;
  final UserModel userModel;
  
  Authenticated(this.firebaseUser, this.userModel);

  @override
  List<Object?> get props => [firebaseUser, userModel];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthLoading()) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData(user);
      } else {
        add(AuthStateChanged(null));
      }
    });

    on<AuthStateChanged>((event, emit) {
      if (event.user == null) {
        emit(Unauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        await _loadUserData(userCredential.user!);
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _auth.signOut();
      emit(Unauthenticated());
    });
  }

  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Force token refresh to ensure latest permissions
      await user.getIdToken(true);
    }
  }

  Future<void> _loadUserData(User firebaseUser) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final userModel = UserModel.fromMap({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email,
          ...userData,
        });
        // ignore: invalid_use_of_visible_for_testing_member
        emit(Authenticated(firebaseUser, userModel));
      } else {
        // Create new user document if it doesn't exist
        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toMap());
        // ignore: invalid_use_of_visible_for_testing_member
        emit(Authenticated(firebaseUser, userModel));
      }
    } catch (e) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(AuthError(e.toString()));
    }
  }
}