import 'package:equatable/equatable.dart';

class Tenant extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? propertyId;
  final DateTime? moveInDate;
  final DateTime createdAt;

  const Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.propertyId,
    this.moveInDate,
    required this.createdAt,
  });

  bool get isAssigned => propertyId != null;

  Tenant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    Object? propertyId = _sentinel,
    Object? moveInDate = _sentinel,
    DateTime? createdAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      propertyId:
          propertyId == _sentinel ? this.propertyId : propertyId as String?,
      moveInDate:
          moveInDate == _sentinel ? this.moveInDate : moveInDate as DateTime?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, phone, propertyId, moveInDate, createdAt];
}

// Sentinel so copyWith can explicitly set nullable fields to null.
const _sentinel = Object();
