import 'dart:async';
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
  final bool forceRefresh;

  const LoadDonors({
    this.bloodGroup,
    this.district,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [bloodGroup, district, forceRefresh];
}

class SearchDonors extends DonorEvent {
  final String query;

  const SearchDonors(this.query);

  @override
  List<Object?> get props => [query];
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
  final DateTime lastUpdated;
  final int totalCount;
  final int availableCount;

  const DonorLoaded({
    required this.donors,
    required this.selectedBloodGroup,
    required this.selectedDistrict,
    required this.lastUpdated,
    required this.totalCount,
    required this.availableCount,
  });

  @override
  List<Object?> get props => [
        donors,
        selectedBloodGroup,
        selectedDistrict,
        lastUpdated,
        totalCount,
        availableCount,
      ];

  DonorLoaded copyWith({
    List<DonorModel>? donors,
    String? selectedBloodGroup,
    String? selectedDistrict,
    DateTime? lastUpdated,
    int? totalCount,
    int? availableCount,
  }) {
    return DonorLoaded(
      donors: donors ?? this.donors,
      selectedBloodGroup: selectedBloodGroup ?? this.selectedBloodGroup,
      selectedDistrict: selectedDistrict ?? this.selectedDistrict,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalCount: totalCount ?? this.totalCount,
      availableCount: availableCount ?? this.availableCount,
    );
  }
}

class DonorError extends DonorState {
  final String message;
  final String? errorCode;

  const DonorError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// Bloc
class DonorBloc extends Bloc<DonorEvent, DonorState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Simple caching mechanism
  static final Map<String, List<DonorModel>> _cache = {};
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  DonorBloc() : super(DonorInitial()) {
    on<LoadDonors>(_onLoadDonors);
    on<SearchDonors>(_onSearchDonors);
  }

  Future<void> _onLoadDonors(
    LoadDonors event,
    Emitter<DonorState> emit,
  ) async {
    try {
      // Show loading only if not refreshing existing data
      if (state is! DonorLoaded) {
        emit(DonorLoading());
      }

      final String cacheKey = '${event.bloodGroup ?? 'All'}_${event.district ?? 'All'}';
      
      // Check cache first (unless force refresh)
      if (!event.forceRefresh && 
          _cache.containsKey(cacheKey) && 
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!).compareTo(_cacheExpiry) < 0) {
        
        final cachedDonors = _cache[cacheKey]!;
        final stats = _calculateStats(cachedDonors);
        
        emit(DonorLoaded(
          donors: cachedDonors,
          selectedBloodGroup: event.bloodGroup ?? 'All',
          selectedDistrict: event.district ?? 'All',
          lastUpdated: _lastCacheUpdate!,
          totalCount: stats['total']!,
          availableCount: stats['available']!,
        ));
        return;
      }

      // Fetch from Firestore
      final donors = await _fetchDonorsFromFirestore(
        bloodGroup: event.bloodGroup,
        district: event.district,
      );

      // Update cache
      _cache[cacheKey] = donors;
      _lastCacheUpdate = DateTime.now();

      final stats = _calculateStats(donors);

      emit(DonorLoaded(
        donors: donors,
        selectedBloodGroup: event.bloodGroup ?? 'All',
        selectedDistrict: event.district ?? 'All',
        lastUpdated: DateTime.now(),
        totalCount: stats['total']!,
        availableCount: stats['available']!,
      ));

    } catch (e) {
      emit(_handleError(e));
    }
  }

  Future<void> _onSearchDonors(
    SearchDonors event,
    Emitter<DonorState> emit,
  ) async {
    if (state is DonorLoaded) {
      final currentState = state as DonorLoaded;
      // This would be handled in the UI layer for better performance
      // But we can emit the same state to trigger UI updates
      emit(currentState);
    }
  }

  Future<List<DonorModel>> _fetchDonorsFromFirestore({
    String? bloodGroup,
    String? district,
  }) async {
    try {
      final DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

      Query query = _firestore
          .collection('users')
          .where('userType', isEqualTo: 'donor')
          .where('isAvailable', isEqualTo: true); // Only fetch available donors

      // Apply filters
      if (bloodGroup != null && bloodGroup != 'All') {
        query = query.where('bloodGroup', isEqualTo: bloodGroup);
      }

      if (district != null && district != 'All') {
        query = query.where('district', isEqualTo: district);
      }

      // Add ordering for consistent results
      query = query.orderBy('name');

      final QuerySnapshot snapshot = await query
          .limit(100) // Limit results for performance
          .get();

      final List<DonorModel> donors = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              data['uid'] = doc.id;
              return DonorModel.fromMap(data);
            } catch (e) {
              // Log individual document parsing errors but don't fail the entire operation
              print('Error parsing donor document ${doc.id}: $e');
              return null;
            }
          })
          .where((donor) => donor != null)
          .cast<DonorModel>()
          .where((donor) {
            // Filter by donation eligibility
            if (donor.lastDonationDate == null) return true;
            return donor.lastDonationDate!.isBefore(threeMonthsAgo);
          })
          .toList();

      return donors;

    } on FirebaseException catch (e) {
      throw DonorException(
        'Firebase error: ${e.message}',
        errorCode: e.code,
      );
    } catch (e) {
      throw DonorException('Failed to fetch donors: $e');
    }
  }

  Map<String, int> _calculateStats(List<DonorModel> donors) {
    final DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    
    int availableCount = 0;
    for (final donor in donors) {
      if (donor.isAvailable && 
          (donor.lastDonationDate == null || 
           donor.lastDonationDate!.isBefore(threeMonthsAgo))) {
        availableCount++;
      }
    }

    return {
      'total': donors.length,
      'available': availableCount,
    };
  }

  DonorError _handleError(dynamic error) {
    if (error is DonorException) {
      return DonorError(error.message, errorCode: error.errorCode);
    }
    
    if (error is FirebaseException) {
      String userFriendlyMessage;
      switch (error.code) {
        case 'permission-denied':
          userFriendlyMessage = 'You don\'t have permission to access donor data.';
          break;
        case 'unavailable':
          userFriendlyMessage = 'Service is currently unavailable. Please try again later.';
          break;
        case 'deadline-exceeded':
          userFriendlyMessage = 'Request timed out. Please check your internet connection.';
          break;
        default:
          userFriendlyMessage = 'Failed to load donors. Please try again.';
      }
      return DonorError(userFriendlyMessage, errorCode: error.code);
    }

    return const DonorError('An unexpected error occurred. Please try again.');
  }

  // Clear cache when needed
  static void clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
  }

  @override
  Future<void> close() {
    // Clear cache when bloc is disposed
    clearCache();
    return super.close();
  }
}

// Custom exception class
class DonorException implements Exception {
  final String message;
  final String? errorCode;

  const DonorException(this.message, {this.errorCode});

  @override
  String toString() => 'DonorException: $message';
}
