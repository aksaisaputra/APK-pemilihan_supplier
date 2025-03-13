import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/result_table.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/criteria_supplier_db_helper.dart';
import 'package:pemilihan_supplier_apk/ui/models/perhitungan_model.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Perhitungan')),
      body: FutureBuilder(
        future: _calculateRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> ranking =
                snapshot.data as List<Map<String, dynamic>>;
            return ResultTable(ranking: ranking);
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _calculateRanking() async {
    CriteriaSupplierDbHelper dbHelper = CriteriaSupplierDbHelper();
    List<Perhitungan> perhitunganList = await dbHelper.getAllPerhitungan();

    // Logika perhitungan Fuzzy AHP
    // (Implementasikan sesuai kebutuhan Anda)

    // Contoh sederhana: Menghitung skor rata-rata
    List<Map<String, dynamic>> ranking = [];
    for (var perhitungan in perhitunganList) {
      ranking.add({
        'idCriteria': perhitungan.idCriteria,
        'idSupplier': perhitungan.idSupplier,
        'value': perhitungan.value,
      });
    }

    // Urutkan berdasarkan nilai tertinggi
    ranking.sort((a, b) => b['value'].compareTo(a['value']));

    return ranking;
  }
}
