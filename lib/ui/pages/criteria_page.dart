import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/criteria_model.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';

class CriteriaPage extends StatefulWidget {
  const CriteriaPage({super.key});

  @override
  State<CriteriaPage> createState() => _CriteriaPageState();
}

class _CriteriaPageState extends State<CriteriaPage> {
  final List<Criteria> _fixedCriteriaList = [
    Criteria(name: 'Kualitas Produk', weight: 5, timestamps: DateTime.now()),
    Criteria(name: 'Harga', weight: 5, timestamps: DateTime.now()),
    Criteria(name: 'Waktu Pengiriman', weight: 5, timestamps: DateTime.now()),
    Criteria(name: 'Kepuasan Pelanggan', weight: 5, timestamps: DateTime.now()),
  ];

  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();

  @override
  void initState() {
    super.initState();
    _loadOrInitializeCriteria();
  }

  Future<void> _loadOrInitializeCriteria() async {
    final existingCriteria = await _dbHelper.getAllCriteria();

    if (existingCriteria.isEmpty) {
      // Insert default criteria if database is empty
      for (var criteria in _fixedCriteriaList) {
        await _dbHelper.insertCriteria(criteria);
      }
    } else {
      // Update the list with data from database
      setState(() {
        _fixedCriteriaList.clear();
        _fixedCriteriaList.addAll(existingCriteria);
      });
    }
  }

  void _showEditWeightDialog(int index) {
    final criteria = _fixedCriteriaList[index];
    final _weightController = TextEditingController(
      text: criteria.weight.toInt().toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Bobot Kriteria'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  criteria.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Bobot (1-9)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Harap isi nilai';
                    final intValue = int.tryParse(value);
                    if (intValue == null) return 'Harus angka bulat';
                    if (intValue < 1 || intValue > 9) return 'Hanya 1-9';
                    return null;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final intValue = int.tryParse(_weightController.text);
                  if (intValue != null && intValue >= 1 && intValue <= 9) {
                    final updatedCriteria = Criteria(
                      id: criteria.id,
                      name: criteria.name,
                      weight: intValue.toDouble(),
                      timestamps: DateTime.now(),
                    );

                    await _dbHelper.updateCriteria(updatedCriteria);
                    setState(() {
                      _fixedCriteriaList[index] = updatedCriteria;
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kriteria'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _fixedCriteriaList.length,
        itemBuilder: (context, index) {
          final criteria = _fixedCriteriaList[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                criteria.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Bobot: ${criteria.weight.toInt()}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditWeightDialog(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
