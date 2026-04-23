import 'package:get_it/get_it.dart';

import 'core/database/database_helper.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Features are registered in their respective milestone implementations.
  // Properties, Tenants, Payments, and Dashboard registrations will be added
  // as each feature is built.
}
