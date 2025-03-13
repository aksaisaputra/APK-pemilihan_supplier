class Perhitungan {
  int? id;
  int idCriteria;
  int idSupplier;
  double value;
  DateTime timestamps;

  Perhitungan({
    this.id,
    required this.idCriteria,
    required this.idSupplier,
    required this.value,
    required this.timestamps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCriteria': idCriteria,
      'idSupplier': idSupplier,
      'value': value,
      'timestamps': timestamps.toIso8601String(),
    };
  }

  factory Perhitungan.fromMap(Map<String, dynamic> map) {
    return Perhitungan(
      id: map['id'],
      idCriteria: map['idCriteria'],
      idSupplier: map['idSupplier'],
      value: map['value'],
      timestamps: DateTime.parse(map['timestamps']),
    );
  }
}