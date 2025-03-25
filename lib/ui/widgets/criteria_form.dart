// import 'package:flutter/material.dart';
// import 'package:pemilihan_supplier_apk/ui/models/criteria_model.dart';

// class CriteriaForm extends StatefulWidget {
//   final Criteria? criteria;
//   final Function(Criteria) onSave;

//   const CriteriaForm({
//     super.key,
//     this.criteria,
//     required this.onSave,
//   });

//   @override
//   State<CriteriaForm> createState() => _CriteriaFormState();
// }

// class _CriteriaFormState extends State<CriteriaForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _weightController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.criteria != null) {
//       _nameController.text = widget.criteria!.name;
//       _weightController.text = widget.criteria!.weight.toString();
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _weightController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.criteria != null;
//     final fixedCriteria = const [
//       'Kualitas Produk',
//       'Harga',
//       'Waktu Pengiriman',
//       'Kepuasan Pelanggan'
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Edit Kriteria' : 'Tambah Kriteria'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(labelText: 'Nama Kriteria'),
//                 readOnly: isEditing && fixedCriteria.contains(widget.criteria?.name),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Nama kriteria tidak boleh kosong';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _weightController,
//                 decoration: const InputDecoration(labelText: 'Bobot (1-9)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Bobot tidak boleh kosong';
//                   }
//                   final numValue = double.tryParse(value);
//                   if (numValue == null) {
//                     return 'Harus berupa angka';
//                   }
//                   if (numValue < 1 || numValue > 9) {
//                     return 'Nilai harus antara 1-9';
//                   }
//                   if (numValue % 1 != 0) {
//                     return 'Hanya bilangan bulat yang diperbolehkan';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     final criteria = Criteria(
//                       id: widget.criteria?.id,
//                       name: _nameController.text,
//                       weight: double.parse(_weightController.text),
//                       timestamps: DateTime.now(),
//                     );
//                     widget.onSave(criteria);
//                     Navigator.pop(context);
//                   }
//                 },
//                 child: Text(isEditing ? 'Simpan Perubahan' : 'Simpan'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CriteriaWeightForm extends StatelessWidget {
//   final Criteria criteria;
//   final Function(Criteria) onSave;

//   const CriteriaWeightForm({
//     super.key,
//     required this.criteria,
//     required this.onSave,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final _weightController = TextEditingController(
//       text: criteria.weight.toInt().toString(),
//     );

//     return AlertDialog(
//       title: const Text('Edit Bobot Kriteria'),
//       content: Form(
//         key: GlobalKey<FormState>(),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               criteria.name,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _weightController,
//               decoration: const InputDecoration(labelText: 'Bobot (1-9)'),
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Bobot tidak boleh kosong';
//                 }
//                 final numValue = int.tryParse(value);
//                 if (numValue == null) {
//                   return 'Harus berupa angka bulat';
//                 }
//                 if (numValue < 1 || numValue > 9) {
//                   return 'Nilai harus antara 1-9';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               children: List.generate(9, (index) {
//                 final number = index + 1;
//                 return ActionChip(
//                   label: Text(number.toString()),
//                   onPressed: () {
//                     _weightController.text = number.toString();
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Batal'),
//         ),
//         TextButton(
//           onPressed: () {
//             if ((Form.of(context) as FormState).validate()) {
//               final updatedCriteria = Criteria(
//                 id: criteria.id,
//                 name: criteria.name,
//                 weight: int.parse(_weightController.text).toDouble(),
//                 timestamps: DateTime.now(),
//               );
//               onSave(updatedCriteria);
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Simpan'),
//         ),
//       ],
//     );
//   }
// }