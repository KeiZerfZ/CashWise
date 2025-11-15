import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String? imagePath; // Path ke file gambar di HP

  const UserProfile({
    required this.name,
    this.imagePath,
  });

  // Bikin profil default
  factory UserProfile.empty() => const UserProfile(name: 'User 1', imagePath: null);

  UserProfile copyWith({
    String? name,
    String? imagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [name, imagePath];
}