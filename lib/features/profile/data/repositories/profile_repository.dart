// lib/features/profile/data/repositories/profile_repository.dart

import 'dart:io';
import 'package:flutter/material.dart'; // <-- BARU: Butuh 'Colors'
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashwise/features/profile/domain/entities/user_profile.dart';
// --- BARU: Import cropper ---
import 'package:image_cropper/image_cropper.dart';

// --- KONTRAK KERJA ---
abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<String?> pickAndSaveImage();
}

// --- IMPLEMENTASI ---
class ProfileRepositoryImpl implements ProfileRepository {
  final SharedPreferences prefs;
  final ImagePicker imagePicker;

  static const _kProfileName = 'profile_name';
  static const _kProfileImage = 'profile_image_path';
  static const _kProfileBgImage = 'profile_bg_image_path';
  static const _kProfileBgColor = 'profile_bg_color_value';

  ProfileRepositoryImpl({required this.prefs, required this.imagePicker});

  @override
  Future<UserProfile> getProfile() async {
    final name = prefs.getString(_kProfileName) ?? 'User 1';
    final imagePath = prefs.getString(_kProfileImage);
    final bgImagePath = prefs.getString(_kProfileBgImage);
    final bgColorValue = prefs.getInt(_kProfileBgColor);

    return UserProfile(
      name: name,
      imagePath: imagePath,
      backgroundImagePath: bgImagePath,
      backgroundColorValue: bgColorValue,
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await prefs.setString(_kProfileName, profile.name);
    await _saveString(_kProfileImage, profile.imagePath);
    await _saveString(_kProfileBgImage, profile.backgroundImagePath);
    await _saveInt(_kProfileBgColor, profile.backgroundColorValue);
  }

  Future<void> _saveString(String key, String? value) async {
    if (value != null && value.isNotEmpty) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  Future<void> _saveInt(String key, int? value) async {
    if (value != null) {
      await prefs.setInt(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  // =================================================================
  // --- INI DIA BAGIAN YANG KITA UBAH ---
  // =================================================================
  @override
  Future<String?> pickAndSaveImage() async {
    // 1. Ambil foto dari galeri
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080, // (Ambil resolusi lebih gede dikit buat di-crop)
    );
    if (image == null) return null; // User batal di galeri

    // 2. [BARU] Lempar ke Cropper
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      // Paksa jadi kotak
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressQuality: 80, // Kompres dikit biar gak kegedean
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Potong Foto Profil',
            toolbarColor: Colors.teal, // Pake warna semantik app lu
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true // Kunci biar tetep kotak
            ),
        IOSUiSettings(
          title: 'Potong Foto Profil',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    // 3. Cek hasil crop
    if (croppedFile == null) return null; // User batal di cropper

    // 4. Cari folder aman di HP
    final directory = await getApplicationDocumentsDirectory();
    // Pake path dari file hasil CROP
    final String extension = p.extension(croppedFile.path); 
    final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
    final newPath = p.join(directory.path, fileName);

    // 5. Copy foto HASIL CROP ke folder aman
    final File imageFile = File(croppedFile.path);
    await imageFile.copy(newPath);

    // 6. Balikin path permanen-nya
    return newPath;
  }
}