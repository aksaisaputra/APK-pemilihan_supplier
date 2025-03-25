import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';

class TextFieldCustom extends StatelessWidget {
  final String label;
  final bool obscureText;  // Diubah dari obsecureText ke obscureText (penulisan yang benar)
  final String? hintText;  // Diubah dari hint ke hintText untuk konsistensi
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const TextFieldCustom({
    Key? key,
    required this.label,
    this.obscureText = false,
    this.hintText,
    this.keyboardType,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: blackTextStyle),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}