import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../properties/domain/entities/property.dart';
import '../../../properties/presentation/bloc/property_bloc.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/usecases/add_tenant.dart';
import '../../domain/usecases/assign_tenant_to_property.dart';
import '../bloc/tenant_bloc.dart';

class TenantFormScreen extends StatefulWidget {
  final Tenant? tenant;

  const TenantFormScreen({super.key, this.tenant});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Store property ID (String) to avoid Equatable/runtimeType comparison issues
  // with DropdownButtonFormField when BLoC rebuilds with new PropertyModel instances.
  String? _selectedPropertyId;

  bool get _isEdit => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant?.name ?? '');
    _emailController = TextEditingController(text: widget.tenant?.email ?? '');
    _phoneController = TextEditingController(text: widget.tenant?.phone ?? '');
    // Pre-select in edit mode from the passed tenant, no BLoC dependency needed.
    _selectedPropertyId = widget.tenant?.propertyId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit(List<Property> allProperties) {
    if (!_formKey.currentState!.validate()) return;

    final tenantBloc = context.read<TenantBloc>();

    if (_isEdit) {
      tenantBloc.add(UpdateTenantEvent(
        widget.tenant!.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      ));

      final previousPropertyId = widget.tenant!.propertyId;

      if (_selectedPropertyId != null &&
          _selectedPropertyId != previousPropertyId) {
        // Assigned to a different (or new) property.
        tenantBloc.add(AssignTenantEvent(
          AssignTenantToPropertyParams(
            tenantId: widget.tenant!.id,
            propertyId: _selectedPropertyId!,
          ),
        ));
      } else if (_selectedPropertyId == null && previousPropertyId != null) {
        // Cleared the assignment.
        tenantBloc.add(UnassignTenantEvent(widget.tenant!.id));
      }
    } else {
      tenantBloc.add(AddTenantEvent(
        AddTenantParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          propertyId: _selectedPropertyId,
        ),
      ));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      builder: (context, propertyState) {
        final allProperties = propertyState is PropertyLoaded
            ? propertyState.properties
            : <Property>[];

        // Show vacant properties + the tenant's current property (so it stays
        // visible in edit mode even though it's marked occupied).
        final eligibleProperties = allProperties
            .where((p) =>
                p.status == PropertyStatus.vacant ||
                p.id == widget.tenant?.propertyId)
            .toList();

        // Guard: if the selected ID is no longer in the eligible list (e.g. the
        // property was deleted externally), reset to avoid a Flutter assertion.
        final selectedIdIsEligible =
            eligibleProperties.any((p) => p.id == _selectedPropertyId);
        if (_selectedPropertyId != null && !selectedIdIsEligible) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => setState(() => _selectedPropertyId = null),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'Edit Tenant' : 'Add Tenant'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => Validators.required(v, field: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 16),
                  // Value type is String? (property ID) — avoids Equatable
                  // runtimeType mismatch when BLoC emits fresh PropertyModel instances.
                  DropdownButtonFormField<String?>(
                    key: ValueKey(_selectedPropertyId),
                    initialValue: selectedIdIsEligible ? _selectedPropertyId : null,
                    decoration: const InputDecoration(
                      labelText: 'Assign Property (optional)',
                      prefixIcon: Icon(Icons.home_work_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('— No property —'),
                      ),
                      ...eligibleProperties.map(
                        (p) => DropdownMenuItem<String?>(
                          value: p.id,
                          child:
                              Text(p.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (id) =>
                        setState(() => _selectedPropertyId = id),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => _submit(allProperties),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        _isEdit ? 'Save Changes' : 'Add Tenant',
                        style: const TextStyle(fontSize: 16),
                      ),
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
