// lib/ui/models/criteria_model.dart
class Criteria {
  final int? id;
  final String name;
  final double weight;
  final DateTime timestamps;

  Criteria({
    this.id,
    required this.name,
    required this.weight,
    required this.timestamps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'timestamps': timestamps.toIso8601String(),
    };
  }

  factory Criteria.fromMap(Map<String, dynamic> map) {
    return Criteria(
      id: map['id'],
      name: map['name'],
      weight: map['weight'],
      timestamps: DateTime.parse(map['timestamps']),
    );
  }

  @override
  String toString() {
    return 'Criteria(id: $id, name: $name, weight: $weight)';
  }
}