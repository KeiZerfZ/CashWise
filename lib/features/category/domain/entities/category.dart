// lib/features/category/domain/entities/category.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final int? id; // Ubah ini jadi int?
  final String name;
  final Color color;
  final String iconName;

  const Category({
    this.id, // Hapus 'required'
    required this.name,
    required this.color,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, name, color, iconName];
}