// lib/features/profile/presentation/bloc/profile_event.dart

import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

/// Perintah: "Coba muat profil yang tersimpan"
class LoadProfile extends ProfileEvent {}

/// Perintah: "Simpan nama baru"
class UpdateProfileName extends ProfileEvent {
  final String newName;
  const UpdateProfileName(this.newName);
  @override
  List<Object> get props => [newName];
}

/// Perintah: "Pilih & simpan foto baru"
class UpdateProfileImage extends ProfileEvent {}

// --- BARU: Event buat background ---

/// Perintah: "Pilih & simpan gambar background baru"
class PickProfileBackgroundImage extends ProfileEvent {}

/// Perintah: "Pilih & simpan warna background baru"
class UpdateProfileBackgroundColor extends ProfileEvent {
  final int colorValue;
  const UpdateProfileBackgroundColor(this.colorValue);
  @override
  List<Object?> get props => [colorValue];
}

/// Perintah: "Reset background ke default (biru)"
class ResetProfileBackground extends ProfileEvent {}