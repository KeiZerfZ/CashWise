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