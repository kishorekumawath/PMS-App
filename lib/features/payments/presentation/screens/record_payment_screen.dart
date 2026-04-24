import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/validators.dart';
import '../../../properties/domain/entities/property.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../../../tenants/domain/entities/tenant.dart';
import '../../../tenants/presentation/bloc/tenant_bloc.dart';
import '../../domain/usecases/record_payment.dart';
import '../bloc/payment_bloc.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedTenantId;
  DateTime? _dueDate;
  DateTime? _paidDate;

  final _dateFmt = DateFormat('dd MMM yyyy');

  // Resolved from tenant selection.
  String? _resolvedPropertyId;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context,
      {required bool isPaidDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isPaidDate) {
        _paidDate = picked;
      } else {
        _dueDate = picked;
      }
    });
  }

  void _onTenantChanged(String? tenantId, List<Tenant> tenants,
      List<Property> properties) {
    setState(() {
      _selectedTenantId = tenantId;
      if (tenantId == null) {
        _resolvedPropertyId = null;
        _amountController.clear();
        return;
      }
      final tenant = tenants.where((t) => t.id == tenantId).firstOrNull;
      _resolvedPropertyId = tenant?.propertyId;

      // Pre-fill amount from the property's monthly rent.
      if (_resolvedPropertyId != null) {
        final property =
            properties.where((p) => p.id == _resolvedPropertyId).firstOrNull;
        if (property != null) {
          _amountController.text =
              property.rentAmount.toStringAsFixed(0);
        }
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }
    if (_resolvedPropertyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Selected tenant has no assigned property.')),
      );
      return;
    }

    context.read<PaymentBloc>().add(
          RecordPaymentEvent(
            RecordPaymentParams(
              tenantId: _selectedTenantId!,
              propertyId: _resolvedPropertyId!,
              amount: double.parse(_amountController.text.trim()),
              dueDate: _dueDate!,
              paidDate: _paidDate,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TenantBloc, TenantState>(
      builder: (context, tenantState) {
        final tenants = tenantState is TenantLoaded
            ? tenantState.tenants.where((t) => t.isAssigned).toList()
            : <Tenant>[];

        final propertyState = context.watch<PropertyBloc>().state;
        final properties = propertyState is PropertyLoaded
            ? propertyState.properties
            : <Property>[];

        final resolvedPropertyName = _resolvedPropertyId != null
            ? properties
                .where((p) => p.id == _resolvedPropertyId)
                .firstOrNull
                ?.name
            : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Record Payment'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tenant dropdown — only assigned tenants.
                  DropdownButtonFormField<String?>(
                    key: ValueKey(_selectedTenantId),
                    initialValue: _selectedTenantId,
                    decoration: const InputDecoration(
                      labelText: 'Tenant',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    hint: const Text('Select tenant'),
                    items: tenants
                        .map((t) => DropdownMenuItem<String?>(
                              value: t.id,
                              child: Text(t.name,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (id) =>
                        _onTenantChanged(id, tenants, properties),
                    validator: (v) =>
                        v == null ? 'Please select a tenant' : null,
                  ),
                  const SizedBox(height: 16),

                  // Auto-filled property.
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Property',
                      prefixIcon: const Icon(Icons.home_work_outlined),
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    child: Text(
                      resolvedPropertyName ?? '— auto-filled from tenant —',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: resolvedPropertyName != null
                                ? null
                                : colorScheme.outline,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount — pre-filled from property rent, still editable.
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      helperText: _resolvedPropertyId != null
                          ? 'Auto-filled from monthly rent — edit to override'
                          : null,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.positiveAmount,
                  ),
                  const SizedBox(height: 16),

                  // Due date picker.
                  InkWell(
                    onTap: () =>
                        _pickDate(context, isPaidDate: false),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        _dueDate != null
                            ? _dateFmt.format(_dueDate!)
                            : 'Tap to select',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _dueDate != null
                                      ? null
                                      : colorScheme.outline,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Paid date picker (optional).
                  InkWell(
                    onTap: () =>
                        _pickDate(context, isPaidDate: true),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Paid Date (optional)',
                        prefixIcon:
                            const Icon(Icons.check_circle_outline),
                        suffixIcon: _paidDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _paidDate = null),
                              )
                            : null,
                      ),
                      child: Text(
                        _paidDate != null
                            ? _dateFmt.format(_paidDate!)
                            : 'Tap to mark as paid',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _paidDate != null
                                      ? Colors.green.shade700
                                      : colorScheme.outline,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes.
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Record Payment',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
