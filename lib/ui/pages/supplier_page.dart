import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/supplier_model.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/supplier_form.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();
  List<Supplier> _supplierList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final suppliers = await _dbHelper.getAllSupplier();
      setState(() => _supplierList = suppliers);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSupplier(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Supplier?'),
        content: const Text('Data tidak dapat dikembalikan'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteSupplier(id);
      _loadSuppliers();
    }
  }

  void _openForm({Supplier? editData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierForm(
          editData: editData,
          onSave: (supplier) async {
            if (editData == null) {
              await _dbHelper.insertSupplier(supplier);
            } else {
              await _dbHelper.updateSupplier(supplier);
            }
            _loadSuppliers();
          },
        ),
      ),
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(supplier.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kontak: ${supplier.contact}'),
            Text('Alamat: ${supplier.address}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _openForm(editData: supplier),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSupplier(supplier.id!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Supplier')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSuppliers,
              child: ListView.builder(
                itemCount: _supplierList.length,
                itemBuilder: (context, index) => 
                  _buildSupplierCard(_supplierList[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}