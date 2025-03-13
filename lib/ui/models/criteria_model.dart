class Criteria {
  int? id;
  String name;
  double weight;
  String type; // 'benefit' atau 'cost'
  DateTime timestamps;

  Criteria({
    this.id,
    required this.name,
    required this.weight,
    required this.type,
    required this.timestamps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'type': type,
      'timestamps': timestamps.toIso8601String(),
    };
  }

  factory Criteria.fromMap(Map<String, dynamic> map) {
    return Criteria(
      id: map['id'],
      name: map['name'],
      weight: map['weight'],
      type: map['type'],
      timestamps: DateTime.parse(map['timestamps']),
    );
  }
}