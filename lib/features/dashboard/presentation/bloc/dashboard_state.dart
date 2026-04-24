import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard_stats.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  const DashboardLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
