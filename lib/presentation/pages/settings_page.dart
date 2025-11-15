import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/presentation/pages/category_management_page.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_state.dart';
import 'package:cashwise/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:cashwise/presentation/pages/help_detail_page.dart';
import 'package:cashwise/presentation/utils/help_content.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text('Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- KARTU PROFIL ---
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              String name = 'User 1';
              String? imagePath;
              if (state is ProfileLoaded) {
                name = state.profile.name;
                imagePath = state.profile.imagePath;
              }

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                    child: imagePath == null
                        ? const Icon(Icons.person, size: 30, color: Colors.white)
                        : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text('Lihat & edit profil'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
                    );
                  },
                ),
              );
            },
          ),
          
          const Divider(height: 40),

          // --- SEKSI APLIKASI ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Utama', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              foregroundColor: Colors.teal.shade800,
              child: const Icon(Icons.category_outlined),
            ),
            title: const Text('Manajemen Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Mode Gelap segera hadir!')),
              );
            },
          ),
          
          const Divider(height: 40),

          // --- SEKSI PUSAT BANTUAN ---
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Pusat Bantuan', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue.shade800,
              child: const Icon(Icons.help_outline),
            ),
            title: const Text('Bantuan Transaksi & Rekap', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpDetailPage(
                    title: 'Bantuan Transaksi',
                    contentWidgets: HelpContent.transaksi,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.1),
              foregroundColor: Colors.teal.shade800,
              child: const Icon(Icons.help_outline),
            ),
            title: const Text('Bantuan Budget', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpDetailPage(
                    title: 'Bantuan Budget',
                    contentWidgets: HelpContent.budget,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              foregroundColor: Colors.green.shade800,
              child: const Icon(Icons.help_outline),
            ),
            title: const Text('Bantuan Celengan Digital', style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpDetailPage(
                    title: 'Bantuan Celengan',
                    contentWidgets: HelpContent.celengan,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}