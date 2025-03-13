import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';
import 'package:pemilihan_supplier_apk/ui/pages/login_page.dart';
import 'package:pemilihan_supplier_apk/ui/pages/home_page.dart'; // Import HomePage
import 'package:pemilihan_supplier_apk/ui/widgets/elevated_button_custom.dart';
import 'package:pemilihan_supplier_apk/ui/widgets/text_field_custom.dart';
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
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
                'Daftar Akun\nAplikasi Pemilihan Supplier Terbaik',
                style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold),
              ),
              const SizedBox(height: 38),
              TextFieldCustom(label: "Email", controller: emailController),
              TextFieldCustom(
                label: "Password",
                obsecureText: true,
                controller: passwordController,
              ),
              ElevatedButtonCustom(
                label: 'Daftar',
                onPressed: () async {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email dan Password tidak boleh kosong'),
                      ),
                    );
                    return;
                  }

                  // Cegah pendaftaran dengan email admin
                  if (emailController.text == 'admin@gmail.com') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Email ini sudah terdaftar sebagai admin',
                        ),
                      ),
                    );
                    return;
                  }

                  User newUser = User(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  try {
                    await _dbHelper.insertUser(newUser);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pendaftaran Berhasil')),
                    );

                    // Pindah ke HomePage setelah pendaftaran berhasil
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
              const SizedBox(height: 69),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sudah punya akun? ', style: greyTextStyle),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
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
}
