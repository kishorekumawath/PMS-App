import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_local_datasource.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDatasource _datasource;

  PaymentRepositoryImpl(this._datasource);

  @override
  Future<List<Payment>> getAllPayments() async {
    try {
      return await _datasource.getAllPayments();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<List<Payment>> getPaymentsForTenant(String tenantId) async {
    try {
      return await _datasource.getPaymentsForTenant(tenantId);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> recordPayment(Payment payment) async {
    try {
      await _datasource.insertPayment(PaymentModel.fromEntity(payment));
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> markAsPaid(String id) async {
    try {
      await _datasource.markAsPaid(id, DateTime.now());
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> deletePayment(String id) async {
    try {
      await _datasource.deletePayment(id);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
