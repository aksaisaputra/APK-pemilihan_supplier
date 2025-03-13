import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/perhitungan_model.dart';

class PerhitunganForm extends StatefulWidget {
  final Function(Perhitungan) onSave;

  const PerhitunganForm({super.key, required this.onSave});

  @override
  State<PerhitunganForm> createState() => _PerhitunganFormState();
}

class _PerhitunganFormState extends State<PerhitunganForm> {
  final _formKey = GlobalKey<FormState>();
  final _idCriteriaController = TextEditingController();
  final _idSupplierController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Perhitungan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idCriteriaController,
                decoration: const InputDecoration(labelText: 'ID Kriteria'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID Kriteria tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ID Kriteria harus berupa angka';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idSupplierController,
                decoration: const InputDecoration(labelText: 'ID Supplier'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID Supplier tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ID Supplier harus berupa angka';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Nilai'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nilai tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Nilai harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Perhitungan perhitungan = Perhitungan(
                      id: null,
                      idCriteria: int.parse(_idCriteriaController.text),
                      idSupplier: int.parse(_idSupplierController.text),
                      value: double.parse(_valueController.text),
                      timestamps: DateTime.now(),
                    );
                    widget.onSave(perhitungan);
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