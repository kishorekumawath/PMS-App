import 'package:get_it/get_it.dart';

import 'core/database/database_helper.dart';

// Properties
import 'features/properties/data/datasources/property_local_datasource.dart';
import 'features/properties/data/repositories/property_repository_impl.dart';
import 'features/properties/domain/repositories/property_repository.dart';
import 'features/properties/domain/usecases/add_property.dart';
import 'features/properties/domain/usecases/delete_property.dart';
import 'features/properties/domain/usecases/get_all_properties.dart';
import 'features/properties/domain/usecases/update_property.dart';
import 'features/properties/presentation/bloc/property_bloc.dart';

// Tenants
import 'features/tenants/data/datasources/tenant_local_datasource.dart';
import 'features/tenants/data/repositories/tenant_repository_impl.dart';
import 'features/tenants/domain/repositories/tenant_repository.dart';
import 'features/tenants/domain/usecases/add_tenant.dart';
import 'features/tenants/domain/usecases/assign_tenant_to_property.dart';
import 'features/tenants/domain/usecases/delete_tenant.dart';
import 'features/tenants/domain/usecases/get_all_tenants.dart';
import 'features/tenants/domain/usecases/update_tenant.dart';
import 'features/tenants/presentation/bloc/tenant_bloc.dart';

// Payments
import 'features/payments/data/datasources/payment_local_datasource.dart';
import 'features/payments/data/repositories/payment_repository_impl.dart';
import 'features/payments/domain/repositories/payment_repository.dart';
import 'features/payments/domain/usecases/delete_payment.dart';
import 'features/payments/domain/usecases/get_all_payments.dart';
import 'features/payments/domain/usecases/record_payment.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core ──────────────────────────────────────────────────────────
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // ── Properties ────────────────────────────────────────────────────
  getIt.registerLazySingleton<PropertyLocalDatasource>(
    () => PropertyLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetAllProperties(getIt()));
  getIt.registerLazySingleton(() => AddProperty(getIt()));
  getIt.registerLazySingleton(() => UpdateProperty(getIt()));
  getIt.registerLazySingleton(() => DeleteProperty(getIt()));
  getIt.registerFactory(
    () => PropertyBloc(
      getAll: getIt(),
      add: getIt(),
      update: getIt(),
      delete: getIt(),
    ),
  );

  // ── Tenants ───────────────────────────────────────────────────────
  getIt.registerLazySingleton<TenantLocalDatasource>(
    () => TenantLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetAllTenants(getIt()));
  getIt.registerLazySingleton(() => AddTenant(getIt()));
  getIt.registerLazySingleton(() => UpdateTenant(getIt()));
  getIt.registerLazySingleton(() => DeleteTenant(getIt()));
  getIt.registerLazySingleton(
    () => AssignTenantToProperty(getIt(), getIt()),
  );
  getIt.registerLazySingleton(
    () => UnassignTenantFromProperty(getIt(), getIt()),
  );
  getIt.registerFactory(
    () => TenantBloc(
      getAll: getIt(),
      add: getIt(),
      update: getIt(),
      delete: getIt(),
      assign: getIt(),
      unassign: getIt(),
    ),
  );

  // ── Payments ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<PaymentLocalDatasource>(
    () => PaymentLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetAllPayments(getIt()));
  getIt.registerLazySingleton(() => RecordPayment(getIt()));
  getIt.registerLazySingleton(() => DeletePayment(getIt()));
  getIt.registerFactory(
    () => PaymentBloc(
      getAll: getIt(),
      record: getIt(),
      delete: getIt(),
    ),
  );
}
