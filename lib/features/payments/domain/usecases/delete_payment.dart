import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class DeletePayment implements UseCase<void, String> {
  final PaymentRepository _repository;

  DeletePayment(this._repository);

  @override
  Future<void> call(String params) {
    return _repository.deletePayment(params);
  }
}
