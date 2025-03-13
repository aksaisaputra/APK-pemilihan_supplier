import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/models/criteria_model.dart';
import 'package:pemilihan_supplier_apk/ui/models/supplier_model.dart';
import 'package:pemilihan_supplier_apk/ui/models/perhitungan_model.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';

class PerhitunganPage extends StatefulWidget {
  const PerhitunganPage({super.key});

  @override
  State<PerhitunganPage> createState() => _PerhitunganPageState();
}

class _PerhitunganPageState extends State<PerhitunganPage> {
  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();
  List<Criteria> _criteriaList = [];
  List<Supplier> _supplierList = [];
  List<Perhitungan> _perhitunganList = [];
  List<Map<String, dynamic>> _fuzzyAHPResults =
      []; // Hasil perhitungan Fuzzy AHP
  List<Map<String, dynamic>> _recommendations = []; // Rekomendasi terbaik

  int? _selectedCriteriaId;
  int? _selectedSupplierId;
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Criteria> criteria = await _dbHelper.getAllCriteria();
    List<Supplier> suppliers = await _dbHelper.getAllSupplier();
    List<Perhitungan> perhitungan = await _dbHelper.getAllPerhitungan();

    setState(() {
      _criteriaList = criteria;
      _supplierList = suppliers;
      _perhitunganList = perhitungan;
    });
  }

  Future<void> _refreshData() async {
    await _loadData(); // Memuat ulang data saat refresh
  }

  // Fungsi untuk menghapus data perhitungan
  Future<void> _deletePerhitungan(int id) async {
    await _dbHelper.deletePerhitungan(id);
    _loadData(); // Memuat ulang data setelah menghapus
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perhitungan berhasil dihapus')),
    );
  }

  // Fungsi untuk mengedit data perhitungan
  Future<void> _editPerhitungan(Perhitungan perhitungan) async {
    _selectedCriteriaId = perhitungan.idCriteria;
    _selectedSupplierId = perhitungan.idSupplier;
    _valueController.text = perhitungan.value.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Perhitungan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown untuk Kriteria
              DropdownButtonFormField<int>(
                value: _selectedCriteriaId,
                items:
                    _criteriaList.map((Criteria criteria) {
                      return DropdownMenuItem<int>(
                        value: criteria.id,
                        child: Text(criteria.name),
                      );
                    }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedCriteriaId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Kriteria',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Dropdown untuk Supplier
              DropdownButtonFormField<int>(
                value: _selectedSupplierId,
                items:
                    _supplierList.map((Supplier supplier) {
                      return DropdownMenuItem<int>(
                        value: supplier.id,
                        child: Text(supplier.name),
                      );
                    }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Input Nilai Perhitungan
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Nilai',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (_selectedCriteriaId == null ||
                    _selectedSupplierId == null ||
                    _valueController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pilih kriteria, supplier, dan isi nilai terlebih dahulu',
                      ),
                    ),
                  );
                  return;
                }

                Perhitungan updatedPerhitungan = Perhitungan(
                  id: perhitungan.id,
                  idCriteria: _selectedCriteriaId!,
                  idSupplier: _selectedSupplierId!,
                  value: double.parse(_valueController.text),
                  timestamps: DateTime.now(),
                );

                await _dbHelper.updatePerhitungan(updatedPerhitungan);
                _loadData(); // Memuat ulang data setelah mengedit
                _valueController.clear(); // Membersihkan input nilai
                setState(() {
                  _selectedCriteriaId = null;
                  _selectedSupplierId = null;
                });

                Navigator.pop(context); // Tutup dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perhitungan berhasil diupdate'),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghitung Fuzzy AHP
  void _calculateFuzzyAHP() {
    // 1. Normalisasi data
    Map<int, List<double>> normalizedData = {};
    for (var perhitungan in _perhitunganList) {
      if (!normalizedData.containsKey(perhitungan.idSupplier)) {
        normalizedData[perhitungan.idSupplier] = [];
      }
      normalizedData[perhitungan.idSupplier]!.add(perhitungan.value);
    }

    // 2. Hitung bobot AHP (contoh sederhana, bobot sama untuk semua kriteria)
    List<double> weights = List.filled(
      _criteriaList.length,
      1.0 / _criteriaList.length,
    );

    // 3. Fuzzyfikasi dan perhitungan Fuzzy AHP
    _fuzzyAHPResults = [];
    normalizedData.forEach((supplierId, values) {
      double fuzzyScore = 0.0;
      for (int i = 0; i < values.length; i++) {
        fuzzyScore += values[i] * weights[i];
      }
      _fuzzyAHPResults.add({
        'supplierId': supplierId,
        'fuzzyScore': fuzzyScore,
      });
    });

    // 4. Urutkan hasil Fuzzy AHP
    _fuzzyAHPResults.sort((a, b) => b['fuzzyScore'].compareTo(a['fuzzyScore']));

    // 5. Ambil 5 rekomendasi terbaik
    _recommendations = _fuzzyAHPResults.take(5).toList();

    setState(() {}); // Perbarui UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perhitungan')),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown untuk Kriteria
              const Text(
                'Pilih Kriteria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: _selectedCriteriaId,
                items:
                    _criteriaList.map((Criteria criteria) {
                      return DropdownMenuItem<int>(
                        value: criteria.id,
                        child: Text(criteria.name),
                      );
                    }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedCriteriaId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Kriteria',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Dropdown untuk Supplier
              const Text(
                'Pilih Supplier',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: _selectedSupplierId,
                items:
                    _supplierList.map((Supplier supplier) {
                      return DropdownMenuItem<int>(
                        value: supplier.id,
                        child: Text(supplier.name),
                      );
                    }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // Input Nilai Perhitungan
              const Text(
                'Nilai Perhitungan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Masukkan Nilai',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Tombol Simpan Perhitungan
              ElevatedButton(
                onPressed: () async {
                  if (_selectedCriteriaId == null ||
                      _selectedSupplierId == null ||
                      _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pilih kriteria, supplier, dan isi nilai terlebih dahulu',
                        ),
                      ),
                    );
                    return;
                  }

                  Perhitungan perhitungan = Perhitungan(
                    id: null,
                    idCriteria: _selectedCriteriaId!,
                    idSupplier: _selectedSupplierId!,
                    value: double.parse(_valueController.text),
                    timestamps: DateTime.now(),
                  );

                  await _dbHelper.insertPerhitungan(perhitungan);
                  _loadData(); // Memuat ulang data setelah menyimpan
                  _valueController.clear(); // Membersihkan input nilai
                  setState(() {
                    _selectedCriteriaId = null;
                    _selectedSupplierId = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perhitungan berhasil disimpan'),
                    ),
                  );
                },
                child: const Text('Simpan Perhitungan'),
              ),

              const SizedBox(height: 20),

              // Tabel Hasil Perhitungan
              const Text(
                'Hasil Perhitungan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DataTable(
                columns: const [
                  DataColumn(label: Text('Kriteria')),
                  DataColumn(label: Text('Supplier')),
                  DataColumn(label: Text('Nilai')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows:
                    _perhitunganList.map((perhitungan) {
                      // Cari nama kriteria berdasarkan ID
                      String criteriaName =
                          _criteriaList
                              .firstWhere(
                                (criteria) =>
                                    criteria.id == perhitungan.idCriteria,
                                orElse:
                                    () => Criteria(
                                      id: -1,
                                      name: 'Unknown',
                                      weight: 0,
                                      type: '',
                                      timestamps: DateTime.now(),
                                    ),
                              )
                              .name;

                      // Cari nama supplier berdasarkan ID
                      String supplierName =
                          _supplierList
                              .firstWhere(
                                (supplier) =>
                                    supplier.id == perhitungan.idSupplier,
                                orElse:
                                    () => Supplier(
                                      id: -1,
                                      name: 'Unknown',
                                      contact: '',
                                      address: '',
                                      timestamps: DateTime.now(),
                                    ),
                              )
                              .name;

                      return DataRow(
                        cells: [
                          DataCell(Text(criteriaName)),
                          DataCell(Text(supplierName)),
                          DataCell(Text(perhitungan.value.toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed:
                                      () => _editPerhitungan(perhitungan),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed:
                                      () => _deletePerhitungan(perhitungan.id!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Tombol Hitung Fuzzy AHP
              ElevatedButton(
                onPressed: _calculateFuzzyAHP,
                child: const Text('Hitung Fuzzy AHP'),
              ),

              const SizedBox(height: 20),

              // Tabel Rekomendasi Fuzzy AHP
              if (_recommendations.isNotEmpty)
                const Text(
                  'Rekomendasi Terbaik (Fuzzy AHP)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              if (_recommendations.isNotEmpty)
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Peringkat')),
                    DataColumn(label: Text('Supplier')),
                    DataColumn(label: Text('Skor Fuzzy AHP')),
                  ],
                  rows:
                      _recommendations.asMap().entries.map((entry) {
                        int rank = entry.key + 1;
                        var recommendation = entry.value;
                        String supplierName =
                            _supplierList
                                .firstWhere(
                                  (supplier) =>
                                      supplier.id ==
                                      recommendation['supplierId'],
                                  orElse:
                                      () => Supplier(
                                        id: -1,
                                        name: 'Unknown',
                                        contact: '',
                                        address: '',
                                        timestamps: DateTime.now(),
                                      ),
                                )
                                .name;

                        return DataRow(
                          cells: [
                            DataCell(Text(rank.toString())),
                            DataCell(Text(supplierName)),
                            DataCell(
                              Text(
                                recommendation['fuzzyScore'].toStringAsFixed(2),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
