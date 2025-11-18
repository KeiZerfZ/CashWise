// lib/presentation/pages/help_detail_page.dart

import 'package:flutter/material.dart';

class HelpDetailPage extends StatelessWidget {
  final String title;
  final List<Widget> contentWidgets;

  const HelpDetailPage({
    super.key,
    required this.title,
    required this.contentWidgets,
  });

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor', biarin theme ---
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        // --- REFAKTOR: Hapus styling, biarin AppBarTheme ---
        backgroundColor: Colors.transparent,
        elevation: 0,
        // foregroundColor: Colors.black87, (Dihapus biar otomatis)
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: contentWidgets, // (Ini udah otomatis ngikut theme)
      ),
    );
  }
}