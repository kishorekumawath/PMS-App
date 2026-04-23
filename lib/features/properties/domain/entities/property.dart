import 'package:equatable/equatable.dart';

enum PropertyStatus { vacant, occupied }

class Property extends Equatable {
  final String id;
  final String name;
  final String address;
  final double rentAmount;
  final PropertyStatus status;
  final DateTime createdAt;

  const Property({
    required this.id,
    required this.name,
    required this.address,
    required this.rentAmount,
    required this.status,
    required this.createdAt,
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    double? rentAmount,
    PropertyStatus? status,
    DateTime? createdAt,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rentAmount: rentAmount ?? this.rentAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, address, rentAmount, status, createdAt];
}
