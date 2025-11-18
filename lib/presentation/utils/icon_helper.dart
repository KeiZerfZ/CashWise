import 'package:flutter/material.dart';

// Kamus ikon kita, sekarang lebih lengkap
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
  
  // BARU: Tambahin ikon-ikon dari BudgetPage lo (kalo belum ada)
  'restaurant': Icons.restaurant,
  'shopping_cart': Icons.shopping_cart,
  'commute': Icons.commute,
  'sports_esports': Icons.sports_esports,
  // Tambahin 'Top Up' kalo ada
  'topup': Icons.credit_card, 
};

/// Fungsi helper untuk "menerjemahkan" nama ikon (String) dari database
/// menjadi objek IconData yang bisa ditampilin di UI.
IconData getIconDataFromString(String iconName) {
  return iconMap[iconName.toLowerCase()] ?? Icons.help;
}