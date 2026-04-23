import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetOverduePayments implements UseCase<List<Payment>, NoParams> {
  final PaymentRepository _repository;

  GetOverduePayments(this._repository);

  @override
  Future<List<Payment>> call(NoParams params) async {
    final all = await _repository.getAllPayments();
    final now = DateTime.now();
    // Any pending payment whose due date has already passed is overdue.
    return all
        .where((p) =>
            p.status == PaymentStatus.pending && p.dueDate.isBefore(now))
        .toList();
  }
}
