import '../../../../core/usecases/usecase.dart';
import '../../../payments/domain/entities/payment.dart';
import '../../../payments/domain/repositories/payment_repository.dart';
import '../../../properties/domain/entities/property.dart';
import '../../../properties/domain/repositories/property_repository.dart';
import '../entities/dashboard_stats.dart';

class GetDashboardStats implements UseCase<DashboardStats, NoParams> {
  final PropertyRepository _propertyRepository;
  final PaymentRepository _paymentRepository;

  GetDashboardStats(this._propertyRepository, this._paymentRepository);

  @override
  Future<DashboardStats> call(NoParams params) async {
    final properties = await _propertyRepository.getAllProperties();
    final payments = await _paymentRepository.getAllPayments();

    final now = DateTime.now();
    final occupied = properties
        .where((p) => p.status == PropertyStatus.occupied)
        .length;

    final overdueList = payments.where((p) =>
        p.status == PaymentStatus.overdue ||
        (p.status == PaymentStatus.pending &&
            p.dueDate.isBefore(now))).toList();

    final thisMonthPaid = payments.where((p) =>
        p.status == PaymentStatus.paid &&
        p.paidDate != null &&
        p.paidDate!.month == now.month &&
        p.paidDate!.year == now.year);

    final sorted = List<Payment>.from(payments)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DashboardStats(
      totalProperties: properties.length,
      occupiedProperties: occupied,
      vacantProperties: properties.length - occupied,
      occupancyRate:
          properties.isEmpty ? 0 : occupied / properties.length,
      totalRentCollectedThisMonth:
          thisMonthPaid.fold(0.0, (sum, p) => sum + p.amount),
      overdueCount: overdueList.length,
      overdueAmount: overdueList.fold(0.0, (sum, p) => sum + p.amount),
      recentPayments: sorted.take(5).toList(),
    );
  }
}
