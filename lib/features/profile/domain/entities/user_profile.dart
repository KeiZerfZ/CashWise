// lib/features/profile/domain/entities/user_profile.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // <-- BARU: Butuh 'ValueGetter'

class UserProfile extends Equatable {
  final String name;
  final String? imagePath; // Path ke file gambar di HP

  // --- BARU: Properti buat background ---
  final String? backgroundImagePath;
  final int? backgroundColorValue;
  // ------------------------------------

  const UserProfile({
    required this.name,
    this.imagePath,
    // --- BARU: Tambah di constructor ---
    this.backgroundImagePath,
    this.backgroundColorValue,
  });

  // Bikin profil default
  factory UserProfile.empty() => const UserProfile(
        name: 'User 1',
        imagePath: null,
        backgroundImagePath: null,
        backgroundColorValue: null,
      );

  // --- REFAKTOR: 'copyWith' ini dibikin lebih canggih ---
  UserProfile copyWith({
    String? name,
    ValueGetter<String?>? imagePath,
    ValueGetter<String?>? backgroundImagePath,
    ValueGetter<int?>? backgroundColorValue,
  }) {
    return UserProfile(
      name: name ?? this.name,
      imagePath: imagePath != null ? imagePath() : this.imagePath,
      backgroundImagePath: backgroundImagePath != null
          ? backgroundImagePath()
          : this.backgroundImagePath,
      backgroundColorValue: backgroundColorValue != null
          ? backgroundColorValue()
          : this.backgroundColorValue,
    );
  }

  @override
  List<Object?> get props =>
      [name, imagePath, backgroundImagePath, backgroundColorValue];
}