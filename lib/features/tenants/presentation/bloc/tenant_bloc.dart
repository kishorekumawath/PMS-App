import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_tenant.dart';
import '../../domain/usecases/assign_tenant_to_property.dart';
import '../../domain/usecases/delete_tenant.dart';
import '../../domain/usecases/get_all_tenants.dart';
import '../../domain/usecases/update_tenant.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';

export 'tenant_event.dart';
export 'tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final GetAllTenants _getAll;
  final AddTenant _add;
  final UpdateTenant _update;
  final DeleteTenant _delete;
  final AssignTenantToProperty _assign;
  final UnassignTenantFromProperty _unassign;

  TenantBloc({
    required GetAllTenants getAll,
    required AddTenant add,
    required UpdateTenant update,
    required DeleteTenant delete,
    required AssignTenantToProperty assign,
    required UnassignTenantFromProperty unassign,
  })  : _getAll = getAll,
        _add = add,
        _update = update,
        _delete = delete,
        _assign = assign,
        _unassign = unassign,
        super(const TenantInitial()) {
    on<LoadTenants>(_onLoad);
    on<AddTenantEvent>(_onAdd);
    on<UpdateTenantEvent>(_onUpdate);
    on<DeleteTenantEvent>(_onDelete);
    on<AssignTenantEvent>(_onAssign);
    on<UnassignTenantEvent>(_onUnassign);
  }

  Future<void> _reload(Emitter<TenantState> emit) async {
    final tenants = await _getAll(const NoParams());
    emit(TenantLoaded(tenants));
  }

  Future<void> _onLoad(LoadTenants event, Emitter<TenantState> emit) async {
    emit(const TenantLoading());
    try {
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onAdd(AddTenantEvent event, Emitter<TenantState> emit) async {
    try {
      await _add(event.params);
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateTenantEvent event, Emitter<TenantState> emit) async {
    try {
      await _update(event.tenant);
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteTenantEvent event, Emitter<TenantState> emit) async {
    try {
      // Free the assigned property (no-op if tenant was unassigned).
      await _unassign(event.id);
      await _delete(event.id);
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onAssign(
      AssignTenantEvent event, Emitter<TenantState> emit) async {
    try {
      await _assign(event.params);
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }

  Future<void> _onUnassign(
      UnassignTenantEvent event, Emitter<TenantState> emit) async {
    try {
      await _unassign(event.tenantId);
      await _reload(emit);
    } catch (e) {
      emit(TenantError(e.toString()));
    }
  }
}
