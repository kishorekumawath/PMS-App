import 'package:get_it/get_it.dart';

import 'core/database/database_helper.dart';
import 'features/properties/data/datasources/property_local_datasource.dart';
import 'features/properties/data/repositories/property_repository_impl.dart';
import 'features/properties/domain/repositories/property_repository.dart';
import 'features/properties/domain/usecases/add_property.dart';
import 'features/properties/domain/usecases/delete_property.dart';
import 'features/properties/domain/usecases/get_all_properties.dart';
import 'features/properties/domain/usecases/update_property.dart';
import 'features/properties/presentation/bloc/property_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Properties — datasource
  getIt.registerLazySingleton<PropertyLocalDatasource>(
    () => PropertyLocalDatasource(getIt()),
  );

  // Properties — repository
  getIt.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(getIt()),
  );

  // Properties — use cases
  getIt.registerLazySingleton(() => GetAllProperties(getIt()));
  getIt.registerLazySingleton(() => AddProperty(getIt()));
  getIt.registerLazySingleton(() => UpdateProperty(getIt()));
  getIt.registerLazySingleton(() => DeleteProperty(getIt()));

  // Properties — BLoC (factory: fresh instance each time)
  getIt.registerFactory(
    () => PropertyBloc(
      getAll: getIt(),
      add: getIt(),
      update: getIt(),
      delete: getIt(),
    ),
  );
}
