import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? bloodGroup;
  final String? address;
  final String? userType; // 'donor' or 'client'
  final DateTime? lastDonationDate;
  final bool isAvailable;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.bloodGroup,
    this.address,
    this.userType,
    this.lastDonationDate,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        uid,
        email,
        name,
        phoneNumber,
        bloodGroup,
        address,
        userType,
        lastDonationDate,
        isAvailable,
      ];

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'bloodGroup': bloodGroup,
      'address': address,
      'userType': userType,
      'lastDonationDate': lastDonationDate?.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      userType: map['userType'],
      lastDonationDate: map['lastDonationDate'] != null
          ? DateTime.parse(map['lastDonationDate'])
          : null,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  UserModel copyWith({
    String? name,
    String? phoneNumber,
    String? bloodGroup,
    String? address,
    String? userType,
    DateTime? lastDonationDate,
    bool? isAvailable,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      userType: userType ?? this.userType,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
