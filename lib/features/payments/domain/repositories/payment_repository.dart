import '../entities/payment.dart';

abstract interface class PaymentRepository {
  Future<List<Payment>> getAllPayments();
  Future<List<Payment>> getPaymentsForTenant(String tenantId);
  Future<void> recordPayment(Payment payment);
  Future<void> deletePayment(String id);
}
