import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/criteria_model.dart';

class CriteriaForm extends StatefulWidget {
  final Function(Criteria) onSave;

  const CriteriaForm({super.key, required this.onSave});

  @override
  State<CriteriaForm> createState() => _CriteriaFormState();
}

class _CriteriaFormState extends State<CriteriaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  String _type = 'benefit';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kriteria'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kriteria'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kriteria tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Bobot'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bobot tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Bobot harus berupa angka';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['benefit', 'cost'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipe Kriteria'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Criteria criteria = Criteria(
                      id: null,
                      name: _nameController.text,
                      weight: double.parse(_weightController.text),
                      type: _type,
                      timestamps: DateTime.now(),
                    );
                    widget.onSave(criteria);
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