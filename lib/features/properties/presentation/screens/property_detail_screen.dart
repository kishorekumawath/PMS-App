import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../router/app_router.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import 'widgets/property_status_badge.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, state) {
        // Always resolve the latest version from BLoC state by ID.
        // Falls back to the constructor argument while loading.
        final current = (state is PropertyLoaded
                ? state.properties.where((p) => p.id == property.id).firstOrNull
                : null) ??
            property;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Property Details'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.propertyEdit,
                  arguments: current,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Property'),
                      content: Text(
                          'Delete "${current.name}"? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context
                        .read<PropertyBloc>()
                        .add(DeletePropertyEvent(current.id));
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.home_work,
                        size: 40, color: colorScheme.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: PropertyStatusBadge(current.status)),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: Icons.home_work_outlined,
                  label: 'Property Name',
                  value: current.name,
                ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: current.address,
                ),
                _DetailRow(
                  icon: Icons.currency_rupee,
                  label: 'Monthly Rent',
                  value: CurrencyFormatter.format(current.rentAmount),
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Listed On',
                  value: DateFormatter.format(current.createdAt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
