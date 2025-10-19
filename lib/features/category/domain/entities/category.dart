import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Entity ini SEKARANG 100% cocok dengan apa yang perlu ditampilkan dan disimpan.
class Category extends Equatable {
  final int id;
  final String name;
  final Color color;
  final String iconName;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.iconName,
  });

  @override
  List<Object?> get props => [id, name, color, iconName];
}