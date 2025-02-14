import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donor_model.dart';

// Events
abstract class DonorDetailEvent extends Equatable {
  const DonorDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadDonorDetail extends DonorDetailEvent {
  final String donorId;

  const LoadDonorDetail(this.donorId);

  @override
  List<Object?> get props => [donorId];
}

// States
abstract class DonorDetailState extends Equatable {
  const DonorDetailState();

  @override
  List<Object?> get props => [];
}

class DonorDetailInitial extends DonorDetailState {}

class DonorDetailLoading extends DonorDetailState {}

class DonorDetailLoaded extends DonorDetailState {
  final DonorModel donor;

  const DonorDetailLoaded(this.donor);

  @override
  List<Object?> get props => [donor];
}

class DonorDetailError extends DonorDetailState {
  final String message;

  const DonorDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DonorDetailBloc extends Bloc<DonorDetailEvent, DonorDetailState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DonorDetailBloc() : super(DonorDetailInitial()) {
    on<LoadDonorDetail>(_onLoadDonorDetail);
  }

  Future<void> _onLoadDonorDetail(
    LoadDonorDetail event,
    Emitter<DonorDetailState> emit,
  ) async {
    emit(DonorDetailLoading());

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(event.donorId)
          .get();

      if (!docSnapshot.exists) {
        emit(const DonorDetailError('Donor not found'));
        return;
      }

      final donor = DonorModel.fromMap(
        docSnapshot.data() as Map<String, dynamic>,
      );

      emit(DonorDetailLoaded(donor));
    } catch (e) {
      emit(DonorDetailError(e.toString()));
    }
  }
}
