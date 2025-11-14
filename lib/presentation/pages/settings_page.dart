import 'package:flutter/material.dart';
// Import "markas" kategori lo
import 'package:cashwise/features/category/presentation/pages/category_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // =================================================================
          // INI DIA TOMBOL MASUK KE MANAJEMEN KATEGORI
          // =================================================================
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              foregroundColor: Colors.teal.shade800,
              child: const Icon(Icons.category_outlined),
            ),
            title: const Text('Manajemen Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Atur kategori pemasukan & pengeluaran'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryManagementPage()),
              );
            },
          ),
          
          // Nanti lo bisa tambahin pengaturan lain di sini
          const SizedBox(height: 10),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade800,
              child: const Icon(Icons.dark_mode_outlined),
            ),
            title: const Text('Mode Tampilan', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Pilih tema terang atau gelap'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              // TODO: Buat halaman ganti tema
            },
          ),
        ],
      ),
    );
  }
}