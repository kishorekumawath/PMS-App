import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/payments/presentation/bloc/payment_bloc.dart';
import 'features/payments/presentation/screens/record_payment_screen.dart';
import 'features/properties/domain/entities/property.dart';
import 'features/properties/presentation/bloc/property_bloc.dart';
import 'features/properties/presentation/screens/property_detail_screen.dart';
import 'features/properties/presentation/screens/property_form_screen.dart';
import 'features/tenants/domain/entities/tenant.dart';
import 'features/tenants/presentation/bloc/tenant_bloc.dart';
import 'features/tenants/presentation/screens/tenant_detail_screen.dart';
import 'features/tenants/presentation/screens/tenant_form_screen.dart';
import 'injection.dart';
import 'router/app_router.dart';
import 'shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const PmsApp());
}

class PmsApp extends StatelessWidget {
  const PmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PropertyBloc>(
          create: (_) => getIt<PropertyBloc>()..add(const LoadProperties()),
        ),
        BlocProvider<TenantBloc>(
          create: (_) => getIt<TenantBloc>()..add(const LoadTenants()),
        ),
        BlocProvider<PaymentBloc>(
          create: (_) => getIt<PaymentBloc>()..add(const LoadPayments()),
        ),
      ],
      child: MaterialApp(
        title: 'PMS',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.home:
              return MaterialPageRoute(builder: (_) => const MainShell());

            // ── Properties ──────────────────────────────────────────
            case AppRoutes.propertyAdd:
              return MaterialPageRoute(
                  builder: (_) => const PropertyFormScreen());

            case AppRoutes.propertyEdit:
              final property = settings.arguments as Property;
              return MaterialPageRoute(
                  builder: (_) => PropertyFormScreen(property: property));

            case AppRoutes.propertyDetail:
              final property = settings.arguments as Property;
              return MaterialPageRoute(
                  builder: (_) => PropertyDetailScreen(property: property));

            // ── Tenants ─────────────────────────────────────────────
            case AppRoutes.tenantAdd:
              return MaterialPageRoute(
                  builder: (_) => const TenantFormScreen());

            case AppRoutes.tenantEdit:
              final tenant = settings.arguments as Tenant;
              return MaterialPageRoute(
                  builder: (_) => TenantFormScreen(tenant: tenant));

            case AppRoutes.tenantDetail:
              final tenant = settings.arguments as Tenant;
              return MaterialPageRoute(
                  builder: (_) => TenantDetailScreen(tenant: tenant));

            // ── Payments ─────────────────────────────────────────────
            case AppRoutes.recordPayment:
              return MaterialPageRoute(
                  builder: (_) => const RecordPaymentScreen());

            default:
              return MaterialPageRoute(builder: (_) => const MainShell());
          }
        },
      ),
    );
  }
}
