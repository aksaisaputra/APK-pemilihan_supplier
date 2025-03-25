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
  // Database helper untuk mengakses data
  final CriteriaSupplierDbHelper _dbHelper = CriteriaSupplierDbHelper();
  
  // Daftar data yang akan ditampilkan
  List<Criteria> _criteriaList = [];
  List<Supplier> _supplierList = [];
  List<Perhitungan> _perhitunganList = [];
  
  // Hasil perhitungan Fuzzy AHP
  List<Map<String, dynamic>> _fuzzyAHPResults = [];
  List<Map<String, dynamic>> _recommendations = [];

  // State untuk form input
  int? _selectedCriteriaId;
  int? _selectedSupplierId;
  final _valueController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData(); // Memuat data saat pertama kali halaman dibuka
  }

  // Fungsi untuk memuat semua data dari database
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _dbHelper.getAllCriteria(),
        _dbHelper.getAllSupplier(),
        _dbHelper.getAllPerhitungan(),
      ]);

      setState(() {
        _criteriaList = results[0] as List<Criteria>;
        _supplierList = results[1] as List<Supplier>;
        _perhitunganList = results[2] as List<Perhitungan>;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi untuk refresh data dengan pull-to-refresh
  Future<void> _refreshData() async {
    // 1. Ambil data supplier terbaru terlebih dahulu
    final suppliers = await _dbHelper.getAllSupplier();
    
    // 2. Update state dengan data terbaru
    setState(() => _supplierList = suppliers);
    
    // 3. Muat ulang semua data
    await _loadData();
    
    // 4. Beri feedback visual
    _showSnackBar('Data telah diperbarui');
  }

  // Fungsi untuk menyimpan perhitungan baru
  Future<void> _savePerhitungan() async {
    // Validasi input
    if (_selectedCriteriaId == null || 
        _selectedSupplierId == null || 
        _valueController.text.isEmpty) {
      _showSnackBar('Pilih kriteria, supplier, dan isi nilai terlebih dahulu');
      return;
    }

    final value = int.tryParse(_valueController.text);
    if (value == null || value < 1 || value > 9) {
      _showSnackBar('Nilai harus bilangan bulat antara 1-9');
      return;
    }

    // Buat objek perhitungan baru
    final perhitungan = Perhitungan(
      id: null,
      idCriteria: _selectedCriteriaId!,
      idSupplier: _selectedSupplierId!,
      value: value.toDouble(),
      timestamps: DateTime.now(),
    );

    // Simpan ke database
    await _dbHelper.insertPerhitungan(perhitungan);
    
    // Bersihkan form dan refresh data
    _clearInputs();
    await _refreshData();
    _showSnackBar('Perhitungan berhasil disimpan');
  }

  // Fungsi untuk mengedit perhitungan
  Future<void> _editPerhitungan(Perhitungan perhitungan) async {
    _selectedCriteriaId = perhitungan.idCriteria;
    _selectedSupplierId = perhitungan.idSupplier;
    _valueController.text = perhitungan.value.toInt().toString();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Perhitungan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCriteriaDropdown(),
              const SizedBox(height: 16),
              _buildSupplierDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Nilai (1-9)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final num = int.tryParse(value ?? '');
                  if (num == null || num < 1 || num > 9) {
                    return 'Masukkan angka 1-9';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(_valueController.text);
              if (value == null || value < 1 || value > 9) {
                _showSnackBar('Nilai harus antara 1-9');
                return;
              }

              final updated = Perhitungan(
                id: perhitungan.id,
                idCriteria: _selectedCriteriaId!,
                idSupplier: _selectedSupplierId!,
                value: value.toDouble(),
                timestamps: DateTime.now(),
              );

              await _dbHelper.updatePerhitungan(updated);
              _clearInputs();
              await _refreshData();
              if (mounted) Navigator.pop(context);
              _showSnackBar('Perhitungan berhasil diupdate');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus perhitungan
  Future<void> _deletePerhitungan(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Perhitungan?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan'),
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
      await _dbHelper.deletePerhitungan(id);
      await _refreshData();
      _showSnackBar('Perhitungan berhasil dihapus');
    }
  }

  // Fungsi untuk menghitung Fuzzy AHP
  void _calculateFuzzyAHP() {
    if (_perhitunganList.isEmpty) {
      _showSnackBar('Tidak ada data perhitungan');
      return;
    }

    // 1. Kelompokkan nilai per supplier
    final Map<int, List<double>> supplierValues = {};
    for (final p in _perhitunganList) {
      supplierValues.putIfAbsent(p.idSupplier, () => []).add(p.value);
    }

    // 2. Hitung bobot (sederhana: bobot sama rata)
    final weights = List.filled(_criteriaList.length, 1.0 / _criteriaList.length);

    // 3. Hitung skor fuzzy
    _fuzzyAHPResults = supplierValues.entries.map((entry) {
      double score = 0.0;
      for (int i = 0; i < entry.value.length && i < weights.length; i++) {
        score += entry.value[i] * weights[i];
      }
      return {
        'supplierId': entry.key,
        'fuzzyScore': score,
      };
    }).toList();

    // 4. Urutkan berdasarkan skor
    _fuzzyAHPResults.sort((a, b) => b['fuzzyScore'].compareTo(a['fuzzyScore']));

    // 5. Ambil 3 rekomendasi terbaik
    _recommendations = _fuzzyAHPResults.take(3).toList();

    setState(() {});
    _showSnackBar('Perhitungan Fuzzy AHP selesai');
  }

  // Widget dropdown untuk memilih kriteria
  Widget _buildCriteriaDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCriteriaId,
      items: _criteriaList.map((c) => DropdownMenuItem(
        value: c.id,
        child: Text(c.name),
      )).toList(),
      onChanged: (value) => setState(() => _selectedCriteriaId = value),
      decoration: const InputDecoration(
        labelText: 'Kriteria',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null ? 'Pilih kriteria' : null,
    );
  }

  // Widget dropdown untuk memilih supplier
  Widget _buildSupplierDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedSupplierId,
      items: _supplierList.map((s) => DropdownMenuItem(
        value: s.id,
        child: Text(s.name),
      )).toList(),
      onChanged: (value) => setState(() => _selectedSupplierId = value),
      decoration: const InputDecoration(
        labelText: 'Supplier',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null ? 'Pilih supplier' : null,
    );
  }

  // Widget form input perhitungan
  Widget _buildInputForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Input Perhitungan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCriteriaDropdown(),
            const SizedBox(height: 16),
            _buildSupplierDropdown(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Nilai (1-9)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                if (num == null || num < 1 || num > 9) {
                  return 'Masukkan angka 1-9';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePerhitungan,
              child: const Text('Simpan Perhitungan'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tabel data (untuk tampilan lebar)
  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Kriteria')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Nilai'), numeric: true),
          DataColumn(label: Text('Aksi')),
        ],
        rows: _perhitunganList.asMap().entries.map((e) {
          final p = e.value;
          final criteria = _criteriaList.firstWhere(
            (c) => c.id == p.idCriteria,
            orElse: () => Criteria(id: -1, name: '-', weight: 0, timestamps: DateTime.now()),
          );
          final supplier = _supplierList.firstWhere(
            (s) => s.id == p.idSupplier,
            orElse: () => Supplier(id: -1, name: '-', contact: '', address: '', timestamps: DateTime.now()),
          );

          return DataRow(
            cells: [
              DataCell(Text('${e.key + 1}')),
              DataCell(Text(criteria.name)),
              DataCell(Text(supplier.name)),
              DataCell(Text(p.value.toInt().toString())),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editPerhitungan(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _deletePerhitungan(p.id!),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Widget list data (untuk tampilan mobile)
  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _perhitunganList.length,
      itemBuilder: (context, index) {
        final p = _perhitunganList[index];
        final criteria = _criteriaList.firstWhere(
          (c) => c.id == p.idCriteria,
          orElse: () => Criteria(id: -1, name: '-', weight: 0, timestamps: DateTime.now()),
        );
        final supplier = _supplierList.firstWhere(
          (s) => s.id == p.idSupplier,
          orElse: () => Supplier(id: -1, name: '-', contact: '', address: '', timestamps: DateTime.now()),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No. ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Nilai: ${p.value.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Kriteria: ${criteria.name}'),
                Text('Supplier: ${supplier.name}'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editPerhitungan(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _deletePerhitungan(p.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget card rekomendasi
  Widget _buildResultsCard() {
    if (_recommendations.isEmpty) return const SizedBox();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rekomendasi Terbaik',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._recommendations.asMap().entries.map((e) {
              final rank = e.key + 1;
              final r = e.value;
              final supplier = _supplierList.firstWhere(
                (s) => s.id == r['supplierId'],
                orElse: () => Supplier(id: -1, name: '-', contact: '', address: '', timestamps: DateTime.now()),
              );

              return ListTile(
                leading: CircleAvatar(child: Text('$rank')),
                title: Text(supplier.name),
                trailing: Text(r['fuzzyScore'].toStringAsFixed(2)),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Bersihkan input form
  void _clearInputs() {
    setState(() {
      _selectedCriteriaId = null;
      _selectedSupplierId = null;
      _valueController.clear();
    });
  }

  // Tampilkan snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perhitungan'),
        actions: [
          // Tombol refresh manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                
                // Implementasi pull-to-refresh
                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputForm(),
                        const SizedBox(height: 20),
                        const Text(
                          'Data Perhitungan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        isWide ? _buildDataTable() : _buildMobileList(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _calculateFuzzyAHP,
                          child: const Text('Hitung Fuzzy AHP'),
                        ),
                        const SizedBox(height: 20),
                        _buildResultsCard(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
}