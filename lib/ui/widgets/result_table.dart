import 'package:flutter/material.dart';

class ResultTable extends StatelessWidget {
  final List<Map<String, dynamic>> ranking;

  const ResultTable({super.key, required this.ranking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID Kriteria')),
          DataColumn(label: Text('ID Supplier')),
          DataColumn(label: Text('Nilai')),
        ],
        rows: ranking.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data['idCriteria'].toString())),
              DataCell(Text(data['idSupplier'].toString())),
              DataCell(Text(data['value'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}