import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsForTenant implements UseCase<List<Payment>, String> {
  final PaymentRepository _repository;

  GetPaymentsForTenant(this._repository);

  @override
  Future<List<Payment>> call(String params) {
    return _repository.getPaymentsForTenant(params);
  }
}
