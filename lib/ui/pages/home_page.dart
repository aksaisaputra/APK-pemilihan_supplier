import 'package:flutter/material.dart';
import 'package:pemilihan_supplier_apk/shared/shared_values.dart';
import 'package:pemilihan_supplier_apk/ui/pages/login_page.dart';
import 'package:pemilihan_supplier_apk/ui/pages/criteria_page.dart';
import 'package:pemilihan_supplier_apk/ui/pages/supplier_page.dart';
import 'package:pemilihan_supplier_apk/ui/pages/perhitungan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Indeks untuk BottomNavigationBar

  // Daftar halaman yang akan ditampilkan
  final List<Widget> _pages = [
    const CriteriaPage(), // Halaman Criteria
    const SupplierPage(), // Halaman Supplier
    const PerhitunganPage(), // Halaman Perhitungan
  ];

  // Fungsi untuk mengubah halaman saat item BottomNavigationBar dipilih
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue, // Warna biru muda untuk AppBar
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultMargin,
            ), // Jarak 1 cm dari kanan
            child: Image.asset(
              'assets/bg3.png',
              width: 40,
              height: 40,
            ), // Sesuaikan ukuran gambar
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Tampilkan halaman yang dipilih
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16.0,
              blurStyle: BlurStyle.outer,
              offset: const Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            useLegacyColorScheme: false,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(color: Colors.blue),
            selectedIconTheme: const IconThemeData(color: Colors.blue),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 0 ? Colors.blue : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/nav/tes.png', // Path ke file PNG
                    width: 24, // Sesuaikan ukuran ikon
                    height: 24,
                  ),
                ),
                label: 'Criteria',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 1 ? Colors.blue : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/nav/tes.png', // Path ke file PNG
                    width: 24, // Sesuaikan ukuran ikon
                    height: 24,
                  ),
                ),
                label: 'Supplier',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _selectedIndex == 2 ? Colors.blue : Colors.grey,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/nav/tes.png', // Path ke file PNG
                    width: 24, // Sesuaikan ukuran ikon
                    height: 24,
                  ),
                ),
                label: 'Perhitungan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
