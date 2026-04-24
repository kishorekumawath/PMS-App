import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/add_property.dart';
import '../bloc/property_bloc.dart';

class PropertyFormScreen extends StatefulWidget {
  final Property? property;

  const PropertyFormScreen({super.key, this.property});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _rentController;
  bool _isSubmitting = false;

  bool get _isEdit => widget.property != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.property?.name ?? '');
    _addressController =
        TextEditingController(text: widget.property?.address ?? '');
    _rentController = TextEditingController(
      text: widget.property != null
          ? widget.property!.rentAmount.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final bloc = context.read<PropertyBloc>();
    if (_isEdit) {
      bloc.add(UpdatePropertyEvent(
        widget.property!.copyWith(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          rentAmount: double.parse(_rentController.text.trim()),
        ),
      ));
    } else {
      bloc.add(AddPropertyEvent(
        AddPropertyParams(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          rentAmount: double.parse(_rentController.text.trim()),
        ),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyBloc, PropertyState>(
      listenWhen: (_, curr) => curr is PropertyError,
      listener: (ctx, state) {
        setState(() => _isSubmitting = false);
        if (state is PropertyError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Property' : 'Add Property'),
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
                    labelText: 'Property Name',
                    prefixIcon: Icon(Icons.home_work_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      Validators.required(v, field: 'Property name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  validator: (v) => Validators.required(v, field: 'Address'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rentController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Rent (₹)',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.positiveAmount,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
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
                            _isEdit ? 'Save Changes' : 'Add Property',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
