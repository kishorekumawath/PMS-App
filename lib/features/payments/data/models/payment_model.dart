import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.tenantId,
    required super.propertyId,
    required super.amount,
    required super.dueDate,
    super.paidDate,
    required super.status,
    super.notes,
    required super.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      propertyId: map['property_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      paidDate: map['paid_date'] != null
          ? DateTime.parse(map['paid_date'] as String)
          : null,
      status: PaymentStatus.values.byName(map['status'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tenant_id': tenantId,
        'property_id': propertyId,
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
        'paid_date': paidDate?.toIso8601String(),
        'status': status.name,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory PaymentModel.fromEntity(Payment entity) => PaymentModel(
        id: entity.id,
        tenantId: entity.tenantId,
        propertyId: entity.propertyId,
        amount: entity.amount,
        dueDate: entity.dueDate,
        paidDate: entity.paidDate,
        status: entity.status,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );
}
