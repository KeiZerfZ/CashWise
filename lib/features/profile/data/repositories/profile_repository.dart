import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashwise/features/profile/domain/entities/user_profile.dart';

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

  // Kunci buat nyimpen di "Lemari"
  static const _kProfileName = 'profile_name';
  static const _kProfileImage = 'profile_image_path';

  ProfileRepositoryImpl({required this.prefs, required this.imagePicker});

  @override
  Future<UserProfile> getProfile() async {
    final name = prefs.getString(_kProfileName) ?? 'User 1';
    final imagePath = prefs.getString(_kProfileImage);
    return UserProfile(name: name, imagePath: imagePath);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await prefs.setString(_kProfileName, profile.name);
    if (profile.imagePath != null) {
      await prefs.setString(_kProfileImage, profile.imagePath!);
    }
  }

  @override
  Future<String?> pickAndSaveImage() async {
    // 1. Ambil foto dari galeri
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (image == null) return null; // User batal

    // 2. Cari folder aman di HP
    final directory = await getApplicationDocumentsDirectory();
    final fileName = p.basename(image.path); // Ambil nama file asli
    final newPath = p.join(directory.path, fileName);

    // 3. Copy foto (file temporary) ke folder aman (file permanen)
    final File imageFile = File(image.path);
    await imageFile.copy(newPath);

    // 4. Balikin path permanen-nya
    return newPath;
  }
}