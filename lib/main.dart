import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/properties/domain/entities/property.dart';
import 'features/properties/presentation/bloc/property_bloc.dart';
import 'features/properties/presentation/screens/property_detail_screen.dart';
import 'features/properties/presentation/screens/property_form_screen.dart';
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
              return MaterialPageRoute(
                  builder: (_) => const MainShell());

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

            default:
              return MaterialPageRoute(
                  builder: (_) => const MainShell());
          }
        },
      ),
    );
  }
}
