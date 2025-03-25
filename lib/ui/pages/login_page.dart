import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';
import 'package:pemilihan_supplier_apk/ui/pages/register_page.dart';
import 'package:pemilihan_supplier_apk/ui/pages/home_page.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/text_field_custom.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/elevated_button_custom.dart';
import 'package:pemilihan_supplier_apk/ui/helpers/database_helper.dart';
import 'package:pemilihan_supplier_apk/ui/models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _dbHelper.getUser(emailController.text);
      
      if (user == null || user.password != passwordController.text) {
        throw Exception('Email atau Password Salah');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
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
                'Selamat Datang 👋\ndi Aplikasi Pemilihan Supplier Terbaik',
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
                hintText: "Masukkan password",
              ),
              const SizedBox(height: 24),
              ElevatedButtonCustom(
                label: 'Sign In',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 69),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: greyTextStyle),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar',
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
    super.dispose();
  }
}