import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../router/app_router.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../../domain/entities/tenant.dart';
import '../bloc/tenant_bloc.dart';

class TenantDetailScreen extends StatelessWidget {
  final Tenant tenant;

  const TenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, state) {
        final current = (state is TenantLoaded
                ? state.tenants.where((t) => t.id == tenant.id).firstOrNull
                : null) ??
            tenant;

        // Resolve property name from PropertyBloc.
        final propertyState = context.watch<PropertyBloc>().state;
        String? propertyName;
        if (current.propertyId != null && propertyState is PropertyLoaded) {
          propertyName = propertyState.properties
              .where((p) => p.id == current.propertyId)
              .firstOrNull
              ?.name;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tenant Details'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.tenantEdit,
                  arguments: current,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove Tenant'),
                      content: Text(
                          'Remove "${current.name}"? This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context
                        .read<TenantBloc>()
                        .add(DeleteTenantEvent(current.id));
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
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      current.name.isNotEmpty
                          ? current.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    current.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: current.email,
                ),
                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: current.phone,
                ),
                _DetailRow(
                  icon: Icons.home_work_outlined,
                  label: 'Assigned Property',
                  value: propertyName ?? 'Unassigned',
                  valueColor: current.isAssigned
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
                if (current.moveInDate != null)
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Move-in Date',
                    value: DateFormatter.format(current.moveInDate!),
                  ),
                _DetailRow(
                  icon: Icons.access_time_outlined,
                  label: 'Added On',
                  value: DateFormatter.format(current.createdAt),
                ),
                if (current.isAssigned) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.link_off),
                    label: const Text('Unassign from Property'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Unassign Property'),
                          content: Text(
                              'Remove ${current.name} from ${propertyName ?? 'this property'}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Unassign'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        context
                            .read<TenantBloc>()
                            .add(UnassignTenantEvent(current.id));
                      }
                    },
                  ),
                ],
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
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
