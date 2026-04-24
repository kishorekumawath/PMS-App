import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class AddTenant implements UseCase<String, AddTenantParams> {
  final TenantRepository _repository;

  AddTenant(this._repository);

  @override
  Future<String> call(AddTenantParams params) async {
    final id = UuidGenerator.generate();
    final tenant = Tenant(
      id: id,
      name: params.name,
      email: params.email,
      phone: params.phone,
      createdAt: DateTime.now(),
    );
    await _repository.addTenant(tenant);
    return id;
  }
}

class AddTenantParams extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String? propertyId;

  const AddTenantParams({
    required this.name,
    required this.email,
    required this.phone,
    this.propertyId,
  });

  @override
  List<Object?> get props => [name, email, phone, propertyId];
}
