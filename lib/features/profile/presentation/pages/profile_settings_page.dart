// lib/features/profile/presentation/pages/profile_settings_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// --- BARU: Import color picker ---
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
      const SnackBar(
          content: Text('Nama berhasil disimpan!'),
          backgroundColor: Colors.green),
    );
  }

  // --- BARU: Fungsi buat milih warna ---
  void _pickBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    Color currentColor = Color(context
            .read<ProfileBloc>()
            .currentProfile
            .backgroundColorValue ??
        theme.primaryColor.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Pilih Warna Latar', style: theme.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              currentColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            labelTextStyle: theme.textTheme.bodyMedium,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              context
                  .read<ProfileBloc>()
                  .add(UpdateProfileBackgroundColor(currentColor.value));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                      backgroundColor: colorScheme.secondaryContainer,
                      backgroundImage:
                          imagePath != null ? FileImage(File(imagePath)) : null,
                      child: imagePath == null
                          ? Icon(Icons.person,
                              size: 60,
                              color: colorScheme.onSecondaryContainer)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
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

              // =================================================================
              // --- BARU: Bagian Latar Belakang ---
              // =================================================================
              const Divider(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text('Latar Belakang Beranda',
                    style: theme.textTheme.titleSmall),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.purple.withOpacity(0.1),
                        foregroundColor: Colors.purple,
                        child: const Icon(Icons.color_lens_outlined),
                      ),
                      title: Text('Pilih Warna',
                          style: theme.textTheme.titleMedium),
                      trailing: Icon(Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant),
                      onTap: () => _pickBackgroundColor(context),
                    ),
                    const Divider(height: 1, indent: 72, endIndent: 16),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        foregroundColor: Colors.orange,
                        child: const Icon(Icons.image_outlined),
                      ),
                      title: Text('Pilih Gambar',
                          style: theme.textTheme.titleMedium),
                      trailing: Icon(Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant),
                      onTap: () {
                        context
                            .read<ProfileBloc>()
                            .add(PickProfileBackgroundImage());
                      },
                    ),
                    const Divider(height: 1, indent: 72, endIndent: 16),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        foregroundColor: theme.primaryColor,
                        child: const Icon(Icons.restart_alt),
                      ),
                      title: Text('Reset ke Default (Biru)',
                          style: theme.textTheme.titleMedium),
                      onTap: () {
                        context
                            .read<ProfileBloc>()
                            .add(ResetProfileBackground());
                      },
                    ),
                  ],
                ),
              )
              // =================================================================
            ],
          );
        },
      ),
    );
  }
}