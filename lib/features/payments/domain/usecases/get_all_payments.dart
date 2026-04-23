import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetAllPayments implements UseCase<List<Payment>, NoParams> {
  final PaymentRepository _repository;

  GetAllPayments(this._repository);

  @override
  Future<List<Payment>> call(NoParams params) {
    return _repository.getAllPayments();
  }
}
