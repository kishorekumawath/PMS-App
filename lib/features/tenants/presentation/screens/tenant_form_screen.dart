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

  String? _selectedPropertyId;
  bool _isSubmitting = false;

  bool get _isEdit => widget.tenant != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant?.name ?? '');
    _emailController = TextEditingController(text: widget.tenant?.email ?? '');
    _phoneController = TextEditingController(text: widget.tenant?.phone ?? '');
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
    setState(() => _isSubmitting = true);

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
        tenantBloc.add(AssignTenantEvent(
          AssignTenantToPropertyParams(
            tenantId: widget.tenant!.id,
            propertyId: _selectedPropertyId!,
          ),
        ));
      } else if (_selectedPropertyId == null && previousPropertyId != null) {
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
    return BlocListener<TenantBloc, TenantState>(
      listenWhen: (_, curr) => curr is TenantError,
      listener: (ctx, state) {
        setState(() => _isSubmitting = false);
        if (state is TenantError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, propertyState) {
          final allProperties = propertyState is PropertyLoaded
              ? propertyState.properties
              : <Property>[];

          final eligibleProperties = allProperties
              .where((p) =>
                  p.status == PropertyStatus.vacant ||
                  p.id == widget.tenant?.propertyId)
              .toList();

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
                    DropdownButtonFormField<String?>(
                      key: ValueKey(_selectedPropertyId),
                      initialValue:
                          selectedIdIsEligible ? _selectedPropertyId : null,
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
                            child: Text(p.name,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (id) =>
                          setState(() => _selectedPropertyId = id),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _submit(allProperties),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
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
      ),
    );
  }
}
