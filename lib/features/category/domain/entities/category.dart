import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final int id; // <-- Balikin jadi int (wajib ada)
  final String name;
  final Color color;
  final String iconName;

  const Category({
    required this.id, // <-- Balikin jadi required
    required this.name,
    required this.color,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, name, color, iconName];
}