// lib/presentation/pages/settings_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart'; // Untuk tombol Import

// Import BLoC & Halaman yang Dibutuhkan
import 'package:cashwise/injection_container.dart' as di;
import 'package:cashwise/features/category/presentation/pages/category_management_page.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_state.dart';
import 'package:cashwise/features/profile/presentation/pages/profile_settings_page.dart';
import 'package:cashwise/presentation/pages/help_detail_page.dart';
import 'package:cashwise/presentation/utils/help_content.dart';
import 'package:cashwise/data/backup/data_backup_bloc.dart';
import 'package:cashwise/data/backup/data_backup_event.dart';
import 'package:cashwise/data/backup/data_backup_state.dart';

// Import Theme Cubit
import 'package:cashwise/presentation/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // (BlocProvider & BlocListener lu udah bener, gak usah diubah)
    return BlocProvider(
      create: (_) => di.locator<DataBackupBloc>(),
      child: BlocListener<DataBackupBloc, DataBackupState>(
        listener: (context, state) {
          if (state is DataBackupLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Memproses data...'),
                  backgroundColor: Colors.blue),
            );
          } else if (state is DataBackupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is DataBackupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: _SettingsPageView(), // Pindahin Scaffold ke widget baru
      ),
    );
  }
}

// Widget ini nampilin UI utamanya
class _SettingsPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ambil theme & colorScheme
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ambil state theme
    final themeMode = context.watch<ThemeCubit>().state;

    return Scaffold(
      // (Warna udah diatur otomatis sama theme di main.dart)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pengaturan',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: colorScheme.secondaryContainer,
                    backgroundImage:
                        imagePath != null ? FileImage(File(imagePath)) : null,
                    child: imagePath == null
                        ? Icon(Icons.person,
                            size: 30, color: colorScheme.onSecondaryContainer)
                        : null,
                  ),
                  title: Text(name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: const Text('Lihat & edit profil'),
                  trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileSettingsPage()),
                    );
                  },
                ),
              );
            },
          ),

          const Divider(height: 40),

          // --- SEKSI APLIKASI ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Utama', style: theme.textTheme.titleSmall),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.1),
              foregroundColor: Colors.teal,
              child: const Icon(Icons.category_outlined),
            ),
            title: Text('Manajemen Kategori', style: theme.textTheme.titleMedium),
            trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoryManagementPage()),
              );
            },
          ),
          const SizedBox(height: 10),

          // --- TOGGLE MODE TAMPILAN ---
          SwitchListTile(
            secondary: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue,
              child: const Icon(Icons.dark_mode_outlined),
            ),
            title: Text('Mode Gelap', style: theme.textTheme.titleMedium),
            subtitle: Text(
                themeMode == ThemeMode.dark ? 'Aktif' : 'Nonaktif',
                style: theme.textTheme.bodySmall),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            value: themeMode == ThemeMode.dark,
            onChanged: (isDark) {
              context.read<ThemeCubit>().toggleTheme(isDark);
            },
          ),
          const SizedBox(height: 10),
          // Opsional: Tombol Reset ke Tema Sistem
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withOpacity(0.1),
              foregroundColor: Colors.grey,
              child: const Icon(Icons.brightness_auto_outlined),
            ),
            title: Text('Ikuti Tema Sistem', style: theme.textTheme.titleMedium),
            subtitle: Text('Otomatis ganti tema berdasarkan HP', style: theme.textTheme.bodySmall),
            trailing: (themeMode == ThemeMode.system)
                ? Icon(Icons.check_circle, color: theme.primaryColor)
                : Icon(Icons.radio_button_unchecked, color: colorScheme.onSurfaceVariant),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onTap: () {
              context.read<ThemeCubit>().setSystemTheme();
            },
          ),

          const Divider(height: 40),

          // --- SEKSI BACKUP & RESTORE ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Data', style: theme.textTheme.titleSmall),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                // EKSPOR / BACKUP
                BlocBuilder<DataBackupBloc, DataBackupState>(
                  builder: (context, state) {
                    final isLoading = state is DataBackupLoading;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.green, strokeWidth: 2))
                            : const Icon(Icons.archive_outlined),
                      ),
                      title: Text('Ekspor (Backup) Data Lokal',
                          style: theme.textTheme.titleMedium),
                      subtitle: const Text('Simpan semua data ke file .csv'),
                      trailing:
                          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                      onTap: isLoading
                          ? null
                          : () {
                              context
                                  .read<DataBackupBloc>()
                                  .add(ExportDataEvent());
                            },
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // IMPOR / RESTORE
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    foregroundColor: Colors.orange,
                    child: const Icon(Icons.cloud_upload_outlined),
                  ),
                  title: Text('Impor (Restore) Data Lokal',
                      style: theme.textTheme.titleMedium),
                  subtitle:
                      const Text('Timpa data dari file .csv (Hati-hati!)'),
                  trailing:
                      Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['csv'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final file = File(result.files.single.path!);
                      context
                          .read<DataBackupBloc>()
                          .add(ImportDataEvent(file: file));
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 40),

          // --- SEKSI PUSAT BANTUAN ---
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text('Pusat Bantuan', style: theme.textTheme.titleSmall),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              foregroundColor: Colors.blue,
              child: const Icon(Icons.help_outline),
            ),
            title: Text('Bantuan Transaksi & Rekap',
                style: theme.textTheme.titleMedium),
            trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            
            // --- INI DIA FIX-NYA ---
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
              foregroundColor: Colors.teal,
              child: const Icon(Icons.help_outline),
            ),
            title: Text('Bantuan Budget', style: theme.textTheme.titleMedium),
            trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            
            // --- INI DIA FIX-NYA ---
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
              foregroundColor: Colors.green,
              child: const Icon(Icons.help_outline),
            ),
            title: Text('Bantuan Celengan Digital',
                style: theme.textTheme.titleMedium),
            trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            tileColor: theme.cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            
            // --- INI DIA FIX-NYA ---
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