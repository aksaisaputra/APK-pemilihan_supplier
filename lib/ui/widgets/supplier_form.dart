import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/supplier_model.dart';

class SupplierForm extends StatefulWidget {
  final Function(Supplier) onSave;

  const SupplierForm({super.key, required this.onSave});

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Supplier'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama supplier tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Kontak'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kontak tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Supplier supplier = Supplier(
                      id: null,
                      name: _nameController.text,
                      contact: _contactController.text,
                      address: _addressController.text,
                      timestamps: DateTime.now(),
                    );
                    widget.onSave(supplier);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}