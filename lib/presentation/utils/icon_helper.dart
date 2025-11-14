import 'package:flutter/material.dart';

// Ini adalah "Kamus" ikon kita.
// Kiri (String) adalah nama yang kita SIMPAN di database.
// Kanan (IconData) adalah ikon yang kita TAMPILKAN di UI.
final Map<String, IconData> iconMap = {
  'default': Icons.category,
  'makanan': Icons.fastfood,
  'transportasi': Icons.directions_bus,
  'tagihan': Icons.receipt,
  'belanja': Icons.shopping_bag,
  'hiburan': Icons.movie,
  'gaji': Icons.attach_money,
  'hadiah': Icons.card_giftcard,
  'kesehatan': Icons.local_hospital,
  'rumah': Icons.home,
  'olahraga': Icons.fitness_center,
  'edukasi': Icons.school,
};

/// Fungsi helper untuk "menerjemahkan" nama ikon (String) dari database
/// menjadi objek IconData yang bisa ditampilin di UI.
IconData getIconDataFromString(String iconName) {
  // Kalo nama ikonnya ada di kamus, pake ikon itu.
  // Kalo gak ada, pake ikon default (Icons.category).
  return iconMap[iconName] ?? Icons.category;
}