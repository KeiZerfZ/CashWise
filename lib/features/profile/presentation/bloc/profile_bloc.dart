import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/profile/data/repositories/profile_repository.dart';
import 'package:cashwise/features/profile/domain/entities/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfileName>(_onUpdateProfileName);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  // Helper buat ngambil state saat ini
  UserProfile get currentProfile => (state is ProfileLoaded)
      ? (state as ProfileLoaded).profile
      : UserProfile.empty();

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
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
        // Hapus foto lama (kalo ada) biar gak numpuk
        final oldPath = currentProfile.imagePath;
        if (oldPath != null && oldPath != newImagePath) {
          final oldFile = File(oldPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }
        
        final updatedProfile = currentProfile.copyWith(imagePath: newImagePath);
        await repository.saveProfile(updatedProfile);
        emit(ProfileLoaded(updatedProfile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}