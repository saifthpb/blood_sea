// lib/core/di/injection.dart
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repositories/user_repository.dart';

final userRepository = UserRepository();
final authBloc = AuthBloc(userRepository);
