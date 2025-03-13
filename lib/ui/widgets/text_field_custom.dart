import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';

class TextFieldCustom extends StatelessWidget {
  final String label;
  final bool obsecureText;
  final TextEditingController? controller;

  const TextFieldCustom({
    Key? key,
    required this.label,
    this.obsecureText = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: blackTextStyle),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obsecureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
