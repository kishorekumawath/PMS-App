import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../properties/domain/entities/property.dart';
import '../../../properties/domain/repositories/property_repository.dart';
import '../repositories/tenant_repository.dart';

class AssignTenantToProperty
    implements UseCase<void, AssignTenantToPropertyParams> {
  final TenantRepository _tenantRepository;
  final PropertyRepository _propertyRepository;

  AssignTenantToProperty(this._tenantRepository, this._propertyRepository);

  @override
  Future<void> call(AssignTenantToPropertyParams params) async {
    final tenant = await _tenantRepository.getTenantById(params.tenantId);

    // Free the old property if the tenant was previously assigned elsewhere.
    if (tenant.propertyId != null &&
        tenant.propertyId != params.propertyId) {
      final oldProperty =
          await _propertyRepository.getPropertyById(tenant.propertyId!);
      await _propertyRepository.updateProperty(
        oldProperty.copyWith(status: PropertyStatus.vacant),
      );
    }

    // Assign tenant → new property.
    await _tenantRepository.updateTenant(
      tenant.copyWith(
        propertyId: params.propertyId,
        moveInDate: DateTime.now(),
      ),
    );

    // Mark new property as occupied.
    final newProperty =
        await _propertyRepository.getPropertyById(params.propertyId);
    await _propertyRepository.updateProperty(
      newProperty.copyWith(status: PropertyStatus.occupied),
    );
  }
}

class UnassignTenantFromProperty implements UseCase<void, String> {
  final TenantRepository _tenantRepository;
  final PropertyRepository _propertyRepository;

  UnassignTenantFromProperty(this._tenantRepository, this._propertyRepository);

  @override
  Future<void> call(String tenantId) async {
    final tenant = await _tenantRepository.getTenantById(tenantId);
    if (tenant.propertyId == null) return;

    // Free the property.
    final property =
        await _propertyRepository.getPropertyById(tenant.propertyId!);
    await _propertyRepository.updateProperty(
      property.copyWith(status: PropertyStatus.vacant),
    );

    // Clear tenant assignment.
    await _tenantRepository.updateTenant(
      tenant.copyWith(propertyId: null, moveInDate: null),
    );
  }
}

class AssignTenantToPropertyParams extends Equatable {
  final String tenantId;
  final String propertyId;

  const AssignTenantToPropertyParams({
    required this.tenantId,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [tenantId, propertyId];
}
