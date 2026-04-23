import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_strings.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/payments/presentation/screens/payment_list_screen.dart';
import '../features/properties/presentation/bloc/property_bloc.dart';
import '../features/properties/presentation/screens/property_list_screen.dart';
import '../features/tenants/presentation/bloc/tenant_bloc.dart';
import '../features/tenants/presentation/screens/tenant_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Prevent cross-sync loops:
  // _syncingProperties: PropertyBloc is being refreshed because a tenant op ran.
  // _syncingTenants:    TenantBloc is being refreshed because a property op ran.
  bool _syncingProperties = false;
  bool _syncingTenants = false;

  static const _tabs = [
    DashboardScreen(),
    PropertyListScreen(),
    TenantListScreen(),
    PaymentListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // When a tenant operation completes → sync properties.
        BlocListener<TenantBloc, TenantState>(
          listenWhen: (prev, curr) =>
              prev is! TenantInitial && curr is TenantLoaded,
          listener: (ctx, _) {
            if (!_syncingTenants) {
              _syncingProperties = true;
              ctx.read<PropertyBloc>().add(const LoadProperties());
            } else {
              _syncingTenants = false;
            }
          },
        ),
        // When a property operation completes → sync tenants.
        BlocListener<PropertyBloc, PropertyState>(
          listenWhen: (prev, curr) =>
              prev is! PropertyInitial && curr is PropertyLoaded,
          listener: (ctx, _) {
            if (!_syncingProperties) {
              _syncingTenants = true;
              ctx.read<TenantBloc>().add(const LoadTenants());
            } else {
              _syncingProperties = false;
            }
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: AppStrings.dashboard,
            ),
            NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              selectedIcon: Icon(Icons.home_work),
              label: AppStrings.properties,
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: AppStrings.tenants,
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: AppStrings.payments,
            ),
          ],
        ),
      ),
    );
  }
}
