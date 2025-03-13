import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/supplier_form.dart';
import 'package:pemilihan_supplier_apk/ui/models/supplier_model.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();
  List<Supplier> _supplierList = [];

  @override
  void initState() {
    super.initState();
    _loadSupplier();
  }

  Future<void> _loadSupplier() async {
    List<Supplier> suppliers = await _dbHelper.getAllSupplier();
    setState(() {
      _supplierList = suppliers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
      ),
      body: ListView.builder(
        itemCount: _supplierList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_supplierList[index].name),
            subtitle: Text('Kontak: ${_supplierList[index].contact}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigasi ke form edit
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _dbHelper.deleteSupplier(_supplierList[index].id!);
                    _loadSupplier();
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupplierForm(
                onSave: (supplier) async {
                  await _dbHelper.insertSupplier(supplier);
                  _loadSupplier();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}