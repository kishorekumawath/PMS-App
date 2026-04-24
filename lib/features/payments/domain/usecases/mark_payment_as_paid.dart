import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class MarkPaymentAsPaid implements UseCase<void, String> {
  final PaymentRepository _repository;

  MarkPaymentAsPaid(this._repository);

  @override
  Future<void> call(String params) {
    return _repository.markAsPaid(params);
  }
}
