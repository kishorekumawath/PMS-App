import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../router/app_router.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../bloc/tenant_bloc.dart';
import 'widgets/tenant_card.dart';

class TenantListScreen extends StatelessWidget {
  const TenantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.tenantAdd),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, state) {
          if (state is TenantLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TenantError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<TenantBloc>().add(const LoadTenants()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is TenantLoaded) {
            if (state.tenants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No tenants yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              );
            }

            // Build a property name lookup map from PropertyBloc state.
            final propertyState = context.watch<PropertyBloc>().state;
            final propertyNames = <String, String>{};
            if (propertyState is PropertyLoaded) {
              for (final p in propertyState.properties) {
                propertyNames[p.id] = p.name;
              }
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<TenantBloc>().add(const LoadTenants()),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.tenants.length,
                itemBuilder: (context, index) {
                  final tenant = state.tenants[index];
                  return TenantCard(
                    tenant: tenant,
                    propertyName: tenant.propertyId != null
                        ? propertyNames[tenant.propertyId]
                        : null,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.tenantDetail,
                      arguments: tenant,
                    ),
                    onDelete: () => context
                        .read<TenantBloc>()
                        .add(DeleteTenantEvent(tenant.id)),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
