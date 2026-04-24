import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

export 'dashboard_event.dart';
export 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStats _getStats;

  DashboardBloc({required GetDashboardStats getStats})
      : _getStats = getStats,
        super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
  }

  Future<void> _onLoad(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final stats = await _getStats(const NoParams());
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
