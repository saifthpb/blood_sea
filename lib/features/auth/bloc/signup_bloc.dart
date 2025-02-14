import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Events
abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends SignUpEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;

  const SignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [name, email, password, phone, address];
}

// States
abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final UserModel user;
  const SignUpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SignUpFailure extends SignUpState {
  final String error;
  const SignUpFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  SignUpBloc() : super(SignUpInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        emit(const SignUpFailure('No internet connection. Please check your network and try again.'));
        return;
      }

      // Create Firebase Authentication user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Create UserModel instance
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: event.email,
        name: event.name,
        phoneNumber: event.phone,
        userType: 'client',
        isAvailable: true,
      );

      // Retry logic for Firestore
      int retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          // Check connectivity again before Firestore operation
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            throw FirebaseException(
              plugin: 'firestore',
              code: 'network-error',
              message: 'Lost internet connection',
            );
          }

          // Store user data in Firestore
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toMap())
              .timeout(const Duration(seconds: 10)); // Add timeout

          // If successful, break the retry loop
          break;
        } on FirebaseException catch (e) {
          retryCount++;
          if (retryCount == maxRetries) {
            // If all retries failed, delete the auth user and throw error
            await userCredential.user?.delete();
            throw FirebaseException(
              plugin: 'firestore',
              code: e.code,
              message: 'Failed to store user data after multiple attempts',
            );
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: retryCount));
          continue;
        }
      }

      // Update user profile in Firebase Auth
      await userCredential.user!.updateDisplayName(event.name);

      emit(SignUpSuccess(userModel));
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        default:
          errorMessage = 'Authentication error: ${e.message}';
      }
      emit(SignUpFailure(errorMessage));
    } on FirebaseException catch (e) {
      emit(SignUpFailure('Database error: ${e.message}'));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      emit(SignUpFailure(e.toString()));
    }
  }

  // Optional: Listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  @override
  Future<void> close() {
    // Clean up any resources here
    return super.close();
  }
}
