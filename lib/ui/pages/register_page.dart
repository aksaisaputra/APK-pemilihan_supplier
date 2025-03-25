import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';
import 'package:pemilihan_supplier_apk/ui/pages/login_page.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/text_field_custom.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/elevated_button_custom.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/database_helper.dart';
import 'package:pemilihan_supplier_apk/ui/models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _register() async {
    // Validate empty fields
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    // Validate email format
    if (!User.isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid. Contoh: user@example.com'),
        ),
      );
      return;
    }

    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    // Validate password length
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbHelper.insertUser(
        User(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultMargin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Image.asset('assets/bg3.png', width: 70, height: 80),
              const SizedBox(height: 13),
              Text(
                'Buat Akun Baru',
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
              ),
              const SizedBox(height: 38),
              TextFieldCustom(
                label: "Email Address",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "contoh@email.com",
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                label: "Password",
                obscureText: true,
                controller: passwordController,
                hintText: "Minimal 6 karakter",
              ),
              const SizedBox(height: 16),
              TextFieldCustom(
                label: "Confirm Password",
                obscureText: true,
                controller: confirmPasswordController,
                hintText: "Konfirmasi password",
              ),
              const SizedBox(height: 24),
              ElevatedButtonCustom(
                label: 'Register',
                isLoading: _isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 69),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: greyTextStyle),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Login',
                      style: blackTextStyle.copyWith(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}