import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';
import 'package:pemilihan_supplier_apk/ui/pages/login_page.dart';
// Import LoginPage

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()), // Perbaikan di sini
      );
    });

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Image.asset('assets/bg1.png', width: 200, height: 220),
      ),
    );
  }
}
