import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class RecordPayment implements UseCase<void, RecordPaymentParams> {
  final PaymentRepository _repository;

  RecordPayment(this._repository);

  @override
  Future<void> call(RecordPaymentParams params) {
    final now = DateTime.now();

    // Derive status: if paidDate is set → paid; if dueDate is past → overdue; else → pending.
    final PaymentStatus status;
    if (params.paidDate != null) {
      status = PaymentStatus.paid;
    } else if (params.dueDate.isBefore(now)) {
      status = PaymentStatus.overdue;
    } else {
      status = PaymentStatus.pending;
    }

    final payment = Payment(
      id: UuidGenerator.generate(),
      tenantId: params.tenantId,
      propertyId: params.propertyId,
      amount: params.amount,
      dueDate: params.dueDate,
      paidDate: params.paidDate,
      status: status,
      notes: params.notes,
      createdAt: now,
    );

    return _repository.recordPayment(payment);
  }
}

class RecordPaymentParams extends Equatable {
  final String tenantId;
  final String propertyId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? notes;

  const RecordPaymentParams({
    required this.tenantId,
    required this.propertyId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [tenantId, propertyId, amount, dueDate, paidDate, notes];
}
