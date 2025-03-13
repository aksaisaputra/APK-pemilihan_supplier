import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/criteria_form.dart';
import 'package:pemilihan_supplier_apk/ui/models/criteria_model.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';

class CriteriaPage extends StatefulWidget {
  const CriteriaPage({super.key});

  @override
  State<CriteriaPage> createState() => _CriteriaPageState();
}

class _CriteriaPageState extends State<CriteriaPage> {
  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();
  List<Criteria> _criteriaList = [];

  @override
  void initState() {
    super.initState();
    _loadCriteria();
  }

  Future<void> _loadCriteria() async {
    List<Criteria> criteria = await _dbHelper.getAllCriteria();
    setState(() {
      _criteriaList = criteria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kriteria'),
      ),
      body: ListView.builder(
        itemCount: _criteriaList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_criteriaList[index].name),
            subtitle: Text('Bobot: ${_criteriaList[index].weight}'),
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
                    await _dbHelper.deleteCriteria(_criteriaList[index].id!);
                    _loadCriteria();
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
              builder: (context) => CriteriaForm(
                onSave: (criteria) async {
                  await _dbHelper.insertCriteria(criteria);
                  _loadCriteria();
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