import 'package:equatable/equatable.dart';

import '../../../payments/domain/entities/payment.dart';

class DashboardStats extends Equatable {
  final int totalProperties;
  final int occupiedProperties;
  final int vacantProperties;
  final double occupancyRate;
  final double totalRentCollectedThisMonth;
  final int overdueCount;
  final double overdueAmount;
  final List<Payment> recentPayments;

  const DashboardStats({
    required this.totalProperties,
    required this.occupiedProperties,
    required this.vacantProperties,
    required this.occupancyRate,
    required this.totalRentCollectedThisMonth,
    required this.overdueCount,
    required this.overdueAmount,
    required this.recentPayments,
  });

  static const empty = DashboardStats(
    totalProperties: 0,
    occupiedProperties: 0,
    vacantProperties: 0,
    occupancyRate: 0,
    totalRentCollectedThisMonth: 0,
    overdueCount: 0,
    overdueAmount: 0,
    recentPayments: [],
  );

  @override
  List<Object?> get props => [
        totalProperties,
        occupiedProperties,
        vacantProperties,
        occupancyRate,
        totalRentCollectedThisMonth,
        overdueCount,
        overdueAmount,
        recentPayments,
      ];
}
