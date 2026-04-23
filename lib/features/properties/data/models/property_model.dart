import '../../domain/entities/property.dart';

class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.name,
    required super.address,
    required super.rentAmount,
    required super.status,
    required super.createdAt,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      rentAmount: (map['rent_amount'] as num).toDouble(),
      status: PropertyStatus.values.byName(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'rent_amount': rentAmount,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory PropertyModel.fromEntity(Property entity) => PropertyModel(
        id: entity.id,
        name: entity.name,
        address: entity.address,
        rentAmount: entity.rentAmount,
        status: entity.status,
        createdAt: entity.createdAt,
      );
}
