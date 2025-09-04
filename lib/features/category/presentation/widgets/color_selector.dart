import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  // Callback untuk mengirim warna yang dipilih ke halaman induk
  final Function(Color) onColorSelected;

  const ColorSelector({super.key, required this.onColorSelected});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  final List<Color> _colors = [
    Colors.red.shade300, Colors.pink.shade200, Colors.purple.shade300,
    Colors.deepPurple.shade300, Colors.indigo.shade300, Colors.blue.shade300,
    Colors.lightBlue.shade300, Colors.cyan.shade300, Colors.teal.shade300,
    Colors.green.shade300, Colors.lightGreen.shade300, Colors.lime.shade300,
    Colors.amber.shade400, Colors.orange.shade400, Colors.deepOrange.shade300,
    Colors.brown.shade300, Colors.blueGrey.shade300, Colors.grey.shade500,
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.first;
    
    // ===== PERBAIKAN DI SINI =====
    // Jangan panggil callback langsung di initState.
    // Jadwalkan untuk dipanggil TEPAT SETELAH build pertama selesai.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onColorSelected(_selectedColor);
      }
    });
    // =============================
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _colors.map((color) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            widget.onColorSelected(_selectedColor);
          },
          borderRadius: BorderRadius.circular(24),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: _selectedColor == color
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}