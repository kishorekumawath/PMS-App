import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../router/app_router.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../../../tenants/presentation/bloc/tenant_bloc.dart';
import '../bloc/payment_bloc.dart';
import 'widgets/payment_tile.dart';

class PaymentListScreen extends StatelessWidget {
  const PaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-payments',
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.recordPayment),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError) {
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
                        .read<PaymentBloc>()
                        .add(const LoadPayments()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentLoaded) {
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

            return Column(
              children: [
                // Filter bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SegmentedButton<PaymentFilter>(
                    segments: const [
                      ButtonSegment(
                          value: PaymentFilter.all, label: Text('All')),
                      ButtonSegment(
                          value: PaymentFilter.paid, label: Text('Paid')),
                      ButtonSegment(
                          value: PaymentFilter.pending,
                          label: Text('Pending')),
                      ButtonSegment(
                          value: PaymentFilter.overdue,
                          label: Text('Overdue')),
                    ],
                    selected: {state.activeFilter},
                    onSelectionChanged: (s) => context
                        .read<PaymentBloc>()
                        .add(FilterPayments(s.first)),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),

                // Payment list
                Expanded(
                  child: state.filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 64,
                                  color:
                                      Theme.of(context).colorScheme.outline),
                              const SizedBox(height: 16),
                              Text(
                                'No payments found.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => context
                              .read<PaymentBloc>()
                              .add(const LoadPayments()),
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: state.filteredPayments.length,
                            itemBuilder: (context, index) {
                              final payment = state.filteredPayments[index];
                              return PaymentTile(
                                payment: payment,
                                tenantName: tenantNames[payment.tenantId] ??
                                    'Unknown',
                                propertyName:
                                    propertyNames[payment.propertyId] ??
                                        'Unknown',
                                onDelete: () => context
                                    .read<PaymentBloc>()
                                    .add(DeletePaymentEvent(payment.id)),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
