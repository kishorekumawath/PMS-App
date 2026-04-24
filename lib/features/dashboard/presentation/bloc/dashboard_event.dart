import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
  @override
  List<Object?> get props => [];
}
