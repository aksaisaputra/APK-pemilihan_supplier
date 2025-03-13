class Supplier {
  int? id;
  String name;
  String contact;
  String address;
  DateTime timestamps;

  Supplier({
    this.id,
    required this.name,
    required this.contact,
    required this.address,
    required this.timestamps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'timestamps': timestamps.toIso8601String(),
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      address: map['address'],
      timestamps: DateTime.parse(map['timestamps']),
    );
  }
}