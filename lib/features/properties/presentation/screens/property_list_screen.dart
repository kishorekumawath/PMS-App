import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../router/app_router.dart';
import '../bloc/property_bloc.dart';
import 'widgets/property_card.dart';

class PropertyListScreen extends StatelessWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-properties',
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.propertyAdd),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PropertyError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<PropertyBloc>()
                        .add(const LoadProperties()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PropertyLoaded) {
            if (state.properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_work_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No properties yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<PropertyBloc>()
                  .add(const LoadProperties()),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: state.properties.length,
                itemBuilder: (context, index) {
                  final property = state.properties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.propertyDetail,
                      arguments: property,
                    ),
                    onDelete: () => context
                        .read<PropertyBloc>()
                        .add(DeletePropertyEvent(property.id)),
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
