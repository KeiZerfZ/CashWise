// lib/features/profile/presentation/bloc/profile_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashwise/features/profile/data/repositories/profile_repository.dart';
import 'package:cashwise/features/profile/domain/entities/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

// =================================================================
// --- INI DIA 3 BARIS YANG KETINGGALAN ---
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // Buat debugPrint
// =================================================================

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;
  final ImagePicker _picker = ImagePicker();

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileName>(_onUpdateProfileName);
    on<UpdateProfileImage>(_onUpdateProfileImage);

    on<PickProfileBackgroundImage>(_onPickProfileBackgroundImage);
    on<UpdateProfileBackgroundColor>(_onUpdateProfileBackgroundColor);
    on<ResetProfileBackground>(_onResetProfileBackground);
  }

  UserProfile get currentProfile => (state is ProfileLoaded)
      ? (state as ProfileLoaded).profile
      : UserProfile.empty();

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) {
      emit(ProfileLoading());
    }
    try {
      final profile = await repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileName(
    UpdateProfileName event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final updatedProfile = currentProfile.copyWith(name: event.newName);
      await repository.saveProfile(updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final newImagePath = await repository.pickAndSaveImage();
      if (newImagePath != null) {
        await _deleteOldFile(currentProfile.imagePath);

        final updatedProfile =
            currentProfile.copyWith(imagePath: () => newImagePath);
        await repository.saveProfile(updatedProfile);
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onPickProfileBackgroundImage(
    PickProfileBackgroundImage event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1080);

      if (image != null) {
        await _deleteOldFile(currentProfile.backgroundImagePath);

        // (Sekarang 'getApplicationDocumentsDirectory' dan 'p' udah dikenalin)
        final directory = await getApplicationDocumentsDirectory();
        final fileName = p.basename(image.path);
        final newPath = p.join(directory.path, fileName);
        await File(image.path).copy(newPath);

        final updatedProfile = currentProfile.copyWith(
          backgroundImagePath: () => newPath,
          backgroundColorValue: () => null,
        );

        await repository.saveProfile(updatedProfile);
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileBackgroundColor(
    UpdateProfileBackgroundColor event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _deleteOldFile(currentProfile.backgroundImagePath);

      final updatedProfile = currentProfile.copyWith(
        backgroundColorValue: () => event.colorValue,
        backgroundImagePath: () => null,
      );

      await repository.saveProfile(updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onResetProfileBackground(
    ResetProfileBackground event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _deleteOldFile(currentProfile.backgroundImagePath);

      final updatedProfile = currentProfile.copyWith(
        backgroundColorValue: () => null,
        backgroundImagePath: () => null,
      );

      await repository.saveProfile(updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _deleteOldFile(String? path) async {
    if (path != null) {
      final oldFile = File(path);
      try {
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        // (Sekarang 'debugPrint' udah dikenalin)
        debugPrint("Gagal hapus file lama: $e");
      }
    }
  }
}