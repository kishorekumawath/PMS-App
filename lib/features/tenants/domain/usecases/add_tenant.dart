import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class AddTenant implements UseCase<void, AddTenantParams> {
  final TenantRepository _repository;

  AddTenant(this._repository);

  @override
  Future<void> call(AddTenantParams params) {
    final tenant = Tenant(
      id: UuidGenerator.generate(),
      name: params.name,
      email: params.email,
      phone: params.phone,
      createdAt: DateTime.now(),
    );
    return _repository.addTenant(tenant);
  }
}

class AddTenantParams extends Equatable {
  final String name;
  final String email;
  final String phone;

  const AddTenantParams({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
