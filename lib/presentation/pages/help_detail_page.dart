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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: contentWidgets, // Langsung tampilkan list widget-nya
      ),
    );
  }
}