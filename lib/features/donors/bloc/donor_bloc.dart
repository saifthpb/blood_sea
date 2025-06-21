import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donor_model.dart';

// Events
abstract class DonorEvent extends Equatable {
  const DonorEvent();

  @override
  List<Object?> get props => [];
}

class LoadDonors extends DonorEvent {
  final String? bloodGroup;
  final String? district;

  const LoadDonors({this.bloodGroup, this.district});

  @override
  List<Object?> get props => [bloodGroup, district];
}

// States
abstract class DonorState extends Equatable {
  const DonorState();

  @override
  List<Object?> get props => [];
}

class DonorInitial extends DonorState {}

class DonorLoading extends DonorState {}

class DonorLoaded extends DonorState {
  final List<DonorModel> donors;
  final String selectedBloodGroup;
  final String selectedDistrict;

  const DonorLoaded({
    required this.donors,
    required this.selectedBloodGroup,
    required this.selectedDistrict,
  });

  @override
  List<Object?> get props => [donors, selectedBloodGroup, selectedDistrict];
}

class DonorError extends DonorState {
  final String message;

  const DonorError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DonorBloc extends Bloc<DonorEvent, DonorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DonorBloc() : super(DonorInitial()) {
    on<LoadDonors>(_onLoadDonors);
  }

  Future<void> _onLoadDonors(
    LoadDonors event,
    Emitter<DonorState> emit,
  ) async {
    emit(DonorLoading());

    try {
      final DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

      Query query = _firestore.collection('users')
          .where('userType', isEqualTo: 'donor');

      if (event.bloodGroup != null && event.bloodGroup != 'All') {
        query = query.where('bloodGroup', isEqualTo: event.bloodGroup);
      }

      if (event.district != null && event.district != 'All') {
        query = query.where('district', isEqualTo: event.district);
      }

      final QuerySnapshot snapshot = await query.get();

      final List<DonorModel> donors = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['uid'] = doc.id; // Add document ID to data
            return DonorModel.fromMap(data);
          })
          .toList(); // Remove the 3-month filtering to show ALL donors

      emit(DonorLoaded(
        donors: donors,
        selectedBloodGroup: event.bloodGroup ?? 'All',
        selectedDistrict: event.district ?? 'All',
      ));
    } catch (e) {
      emit(DonorError(e.toString()));
    }
  }
}
