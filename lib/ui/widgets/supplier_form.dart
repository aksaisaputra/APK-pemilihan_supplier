import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/supplier_model.dart';

class SupplierForm extends StatefulWidget {
  final Supplier? editData;
  final Function(Supplier) onSave;

  const SupplierForm({
    super.key,
    this.editData,
    required this.onSave,
  });

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      _nameController.text = widget.editData!.name;
      _contactController.text = widget.editData!.contact;
      _addressController.text = widget.editData!.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final supplier = Supplier(
      id: widget.editData?.id,
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      timestamps: DateTime.now(),
    );

    widget.onSave(supplier);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editData == null ? 'Tambah Supplier' : 'Edit Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Supplier',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Kontak',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Kontak tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}