// lib/features/profile/presentation/pages/profile_settings_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_event.dart';
import 'package:cashwise/features/profile/presentation/bloc/profile_state.dart';
import 'package:cashwise/presentation/widgets/common/custom_text_form_field.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final currentProfile = context.read<ProfileBloc>().currentProfile;
    _nameController = TextEditingController(text: currentProfile.name);
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_nameController.text.isEmpty) return;
    context.read<ProfileBloc>().add(UpdateProfileName(_nameController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      // (Warna SnackBar SEMANTIK, biarin)
      const SnackBar(
          content: Text('Nama berhasil disimpan!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor' ---
      appBar: AppBar(
        title: const Text('Edit Profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
        // --- REFAKTOR: Hapus styling, biarin AppBarTheme ---
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          String? imagePath;
          String currentName = 'User 1';

          if (state is ProfileLoaded) {
            imagePath = state.profile.imagePath;
            currentName = state.profile.name;
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Bagian Foto Profil ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      // --- REFAKTOR: Ganti warna hardcode ---
                      backgroundColor: colorScheme.secondaryContainer,
                      backgroundImage:
                          imagePath != null ? FileImage(File(imagePath)) : null,
                      child: imagePath == null
                          // --- REFAKTOR: Ganti warna hardcode ---
                          ? Icon(Icons.person,
                              size: 60,
                              color: colorScheme.onSecondaryContainer)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        // (Warna ini SEMANTIK = Aksi Primer, biarin)
                        backgroundColor: theme.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            context
                                .read<ProfileBloc>()
                                .add(UpdateProfileImage());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Bagian Nama ---
              // (Widget ini udah otomatis ngikut theme
              // karena kita benerin file-nya di langkah 1)
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama Panggilan',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value!.isEmpty ? 'Nama gak boleh kosong' : null,
                onFieldSubmitted: (_) => _saveName(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveName,
                  style: ElevatedButton.styleFrom(
                    // (Warna ini SEMANTIK = Aksi Simpan, biarin)
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Nama',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}