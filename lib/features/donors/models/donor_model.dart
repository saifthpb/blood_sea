import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DonorModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String bloodGroup;
  final String district;
  final String thana;
  final DateTime? lastDonationDate;
  final bool isAvailable;

  const DonorModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.district,
    required this.thana,
    this.lastDonationDate,
    this.isAvailable = true,
  });

  factory DonorModel.fromMap(Map<String, dynamic> map) {
    return DonorModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      district: map['district'] ?? '',
      thana: map['thana'] ?? '',
      lastDonationDate: (map['lastDonationDate'] as Timestamp?)?.toDate(),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phoneNumber,
        bloodGroup,
        district,
        thana,
        lastDonationDate,
        isAvailable,
      ];
}
