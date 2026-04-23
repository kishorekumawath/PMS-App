import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  const TenantModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.propertyId,
    super.moveInDate,
    required super.createdAt,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      propertyId: map['property_id'] as String?,
      moveInDate: map['move_in_date'] != null
          ? DateTime.parse(map['move_in_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'property_id': propertyId,
        'move_in_date': moveInDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  factory TenantModel.fromEntity(Tenant entity) => TenantModel(
        id: entity.id,
        name: entity.name,
        email: entity.email,
        phone: entity.phone,
        propertyId: entity.propertyId,
        moveInDate: entity.moveInDate,
        createdAt: entity.createdAt,
      );
}
