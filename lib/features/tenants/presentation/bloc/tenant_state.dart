import 'package:equatable/equatable.dart';

import '../../domain/entities/tenant.dart';

sealed class TenantState extends Equatable {
  const TenantState();
}

class TenantInitial extends TenantState {
  const TenantInitial();
  @override
  List<Object?> get props => [];
}

class TenantLoading extends TenantState {
  const TenantLoading();
  @override
  List<Object?> get props => [];
}

class TenantLoaded extends TenantState {
  final List<Tenant> tenants;
  const TenantLoaded(this.tenants);
  @override
  List<Object?> get props => [tenants];
}

class TenantError extends TenantState {
  final String message;
  const TenantError(this.message);
  @override
  List<Object?> get props => [message];
}
