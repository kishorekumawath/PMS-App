import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../../../tenants/presentation/bloc/tenant_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import 'widgets/occupancy_chart.dart';
import 'widgets/recent_payments_list.dart';
import 'widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<DashboardBloc>()
                        .add(const LoadDashboard()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            final stats = state.stats;

            // Build name lookup maps from sibling BLoCs.
            final tenantState = context.watch<TenantBloc>().state;
            final propertyState = context.watch<PropertyBloc>().state;
            final tenantNames = <String, String>{};
            final propertyNames = <String, String>{};
            if (tenantState is TenantLoaded) {
              for (final t in tenantState.tenants) {
                tenantNames[t.id] = t.name;
              }
            }
            if (propertyState is PropertyLoaded) {
              for (final p in propertyState.properties) {
                propertyNames[p.id] = p.name;
              }
            }

            return RefreshIndicator(
              onRefresh: () async => context
                  .read<DashboardBloc>()
                  .add(const LoadDashboard()),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stat cards (2×2 grid) ──────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: MediaQuery.sizeOf(context).width < 400 ? 1.1 : 1.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          label: 'Total Properties',
                          value: stats.totalProperties.toString(),
                          icon: Icons.home_work,
                          color: Colors.blue,
                        ),
                        StatCard(
                          label: 'Occupied',
                          value: stats.occupiedProperties.toString(),
                          icon: Icons.people,
                          color: Colors.green,
                        ),
                        StatCard(
                          label: 'Overdue',
                          value: stats.overdueCount.toString(),
                          icon: Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        StatCard(
                          label: "This Month's Rent",
                          value: CurrencyFormatter.format(
                              stats.totalRentCollectedThisMonth),
                          icon: Icons.currency_rupee,
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Occupancy chart ────────────────────────────
                    _SectionCard(
                      title: 'Occupancy Overview',
                      child: SizedBox(
                        height: 160,
                        child: OccupancyChart(
                          occupied: stats.occupiedProperties,
                          vacant: stats.vacantProperties,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Overdue summary ────────────────────────────
                    if (stats.overdueCount > 0)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${stats.overdueCount} overdue payment${stats.overdueCount > 1 ? 's' : ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    'Total: ${CurrencyFormatter.format(stats.overdueAmount)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.red.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Recent payments ────────────────────────────
                    _SectionCard(
                      title: 'Recent Payments',
                      child: RecentPaymentsList(
                        payments: stats.recentPayments,
                        tenantNames: tenantNames,
                        propertyNames: propertyNames,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
