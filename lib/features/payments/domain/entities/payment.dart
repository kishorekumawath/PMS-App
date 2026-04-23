import 'package:equatable/equatable.dart';

enum PaymentStatus { paid, pending, overdue }

class Payment extends Equatable {
  final String id;
  final String tenantId;
  final String propertyId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final String? notes;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        propertyId,
        amount,
        dueDate,
        paidDate,
        status,
        notes,
        createdAt,
      ];
}
