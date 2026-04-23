import 'package:equatable/equatable.dart';

import '../../domain/entities/tenant.dart';
import '../../domain/usecases/add_tenant.dart';
import '../../domain/usecases/assign_tenant_to_property.dart';

sealed class TenantEvent extends Equatable {
  const TenantEvent();
}

class LoadTenants extends TenantEvent {
  const LoadTenants();
  @override
  List<Object?> get props => [];
}

class AddTenantEvent extends TenantEvent {
  final AddTenantParams params;
  const AddTenantEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UpdateTenantEvent extends TenantEvent {
  final Tenant tenant;
  const UpdateTenantEvent(this.tenant);
  @override
  List<Object?> get props => [tenant];
}

class DeleteTenantEvent extends TenantEvent {
  final String id;
  const DeleteTenantEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class AssignTenantEvent extends TenantEvent {
  final AssignTenantToPropertyParams params;
  const AssignTenantEvent(this.params);
  @override
  List<Object?> get props => [params];
}

class UnassignTenantEvent extends TenantEvent {
  final String tenantId;
  const UnassignTenantEvent(this.tenantId);
  @override
  List<Object?> get props => [tenantId];
}
