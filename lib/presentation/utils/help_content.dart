// lib/presentation/utils/help_content.dart

import 'package:flutter/material.dart';

/// Widget helper simpel buat bikin bagian panduan
class _HelpSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _HelpSection(
      {required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme & colorScheme ---
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // --- REFAKTOR: Ganti warna hardcode ---
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        // --- REFAKTOR: Ganti border hardcode ---
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            // (Ini udah bener, pake theme.primaryColor)
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            foregroundColor: theme.primaryColor,
            radius: 20,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  // --- REFAKTOR: Ganti style hardcode ---
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  // --- REFAKTOR: Ganti style hardcode ---
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// INI DIA ISI PANDUANNYA
// (TIDAK ADA PERUBAHAN DI SINI, KARENA OTOMATIS NGECAT ULANG)
// =================================================================

class HelpContent {
  /// --- PANDUAN UNTUK TRANSAKSI & REKAP ---
  static const List<Widget> transaksi = [
    _HelpSection(
      icon: Icons.filter_alt,
      title: 'Filter Canggih (H/M/B/T)',
      content:
          'Gunakan tombol "Bulanan", "Mingguan", "Harian", atau "Tahunan" untuk mengubah jangkauan data yang ditampilkan. Data di daftar transaksi dan halaman grafik akan otomatis ter-filter.',
    ),
    _HelpSection(
      icon: Icons.calendar_today,
      title: 'Pilih Tanggal, Bulan, atau Tahun',
      content:
          'Klik tombol biru di atas untuk membuka kalender atau pemilih tahun. Tanggal yang kamu pilih akan menjadi acuan untuk filter Harian, Mingguan, dan Bulanan.',
    ),
    _HelpSection(
      icon: Icons.bar_chart,
      title: 'Lihat Grafik',
      content:
          'Tombol "Lihat Grafik" akan membuka halaman analisis visual. Grafik akan otomatis menyesuaikan berdasarkan filter (H/M/B/T) yang sedang aktif.',
    ),
    _HelpSection(
      icon: Icons.edit_note,
      title: 'Edit & Hapus Transaksi',
      content:
          'Klik pada salah satu item di daftar transaksi untuk membuka detail. Di sana kamu akan menemukan tombol "Edit" dan "Hapus".',
    ),
  ];

  /// --- PANDUAN UNTUK BUDGET ---
  static const List<Widget> budget = [
    _HelpSection(
      icon: Icons.account_balance_wallet,
      title: 'Apa itu Budget?',
      content:
          'Budget adalah fitur untuk menentukan batas maksimal pengeluaran untuk sebuah kategori dalam satu bulan. Ini membantumu mengontrol pengeluaran agar tidak boros.',
    ),
    _HelpSection(
      icon: Icons.add,
      title: 'Cara Membuat Budget',
      content:
          'Masuk ke tab "Budget", lalu tekan tombol "+" di tengah bawah. Pilih kategori dan masukkan jumlah maksimal anggaran untuk bulan yang dipilih.',
    ),
    _HelpSection(
      icon: Icons.compare_arrows,
      title: 'Membaca Progress Bar',
      content:
          'Progress bar menunjukkan perbandingan antara uang yang sudah kamu belanjakan (real) dengan batas budget yang kamu tentukan. Jika bar berwarna merah, artinya kamu sudah overbudget!',
    ),
    _HelpSection(
      icon: Icons.delete_forever,
      title: 'Edit & Hapus Budget',
      content:
          'Klik pada salah satu kartu budget untuk mengedit jumlahnya. Kamu juga bisa menekan ikon tong sampah di kartu untuk menghapus budget di bulan tersebut.',
    ),
  ];

  /// --- PANDUAN UNTUK CELENGAN DIGITAL ---
  static const List<Widget> celengan = [
    _HelpSection(
      icon: Icons.savings,
      title: 'Apa itu Celengan Digital?',
      content:
          'Fitur ini membantumu menabung untuk tujuan tertentu (misal: "Beli PS5"). Kamu bisa melihat progress tabunganmu secara visual.',
    ),
    _HelpSection(
      icon: Icons.add,
      title: 'Cara Membuat Celengan',
      content:
          'Masuk ke tab "Celengan", lalu tekan tombol "+" di tengah bawah. Beri nama celenganmu dan tentukan berapa target uang yang ingin kamu kumpulkan.',
    ),
    _HelpSection(
      icon: Icons.arrow_downward,
      title: 'Cara Menambah Setoran',
      content:
          'Klik pada salah satu celenganmu untuk membuka halaman detail. Di halaman itu, tekan tombol "+" hijau di pojok kanan bawah untuk menambahkan setoran baru.',
    ),
    _HelpSection(
      icon: Icons.delete_forever,
      title: 'Hapus Celengan',
      content:
          'Masuk ke halaman detail celengan, lalu tekan ikon tong sampah di pojok kanan atas (di AppBar) untuk menghapus celengan beserta seluruh riwayat setorannya.',
    ),
  ];
}