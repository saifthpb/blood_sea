// lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

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
  final UserRepository _userRepository;

  AuthBloc(this._userRepository) : super(AuthLoading()) {
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
        
        // Update user's online status and last seen
        if (userCredential.user != null) {
          await _userRepository.updateUserStatus(
            userCredential.user!.uid, 
            UserStatus.online
          );
          await _loadUserData(userCredential.user!);
        }
      } catch (e) {
        emit(AuthError(_getErrorMessage(e)));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          // Update user's status to offline before logging out
          await _userRepository.updateUserStatus(user.uid, UserStatus.offline);
          // Clear FCM token
          await _userRepository.updateFcmToken(user.uid, null);
        }
        await _auth.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(_getErrorMessage(e)));
      }
    });
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Force token refresh to ensure latest permissions
        await user.getIdToken(true);
        await _loadUserData(user);
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  Future<void> _loadUserData(User firebaseUser) async {
    try {
      final userModel = await _userRepository.getUserById(firebaseUser.uid);

      if (userModel != null) {
        emit(Authenticated(firebaseUser, userModel));
      } else {
        // Create new user document if it doesn't exist
        final newUserModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          userType: 'client',
          name: firebaseUser.displayName,
          status: UserStatus.online,
        );

        await _userRepository.createUser(
          uid: newUserModel.uid,
          email: newUserModel.email,
          name: newUserModel.name ?? '',
          phoneNumber: '',
          bloodGroup: '',
          district: '',
          thana: '',
          userType: 'client',
        );

        emit(Authenticated(firebaseUser, newUserModel));
      }
    } catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many unsuccessful login attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled. Please contact support.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return 'An error occurred during authentication.';
      }
    }
    return error.toString();
  }

  @override
  Future<void> close() {
    // Update user status to offline when bloc is closed
    final user = _auth.currentUser;
    if (user != null) {
      _userRepository.updateUserStatus(user.uid, UserStatus.offline);
    }
    return super.close();
  }
}
