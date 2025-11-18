<div align="center">

  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" alt="CashWise Logo" width="100" height="100">

  # **CashWise 💰**

  **Kelola Keuanganmu. Capai Targetmu.**

  Aplikasi manajemen keuangan pribadi berbasis Flutter yang fokus pada performa (120fps), kustomisasi, dan kemudahan penggunaan.

  <br>

  [![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-2.19-0175C2?style=for-the-badge&logo=dart)](https://dart.dev/)
  [![State Management](https://img.shields.io/badge/State-BLoC-blue?style=for-the-badge)](https://bloclibrary.dev/)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)]()

</div>

---

## 📱 Tentang CashWise

**CashWise** adalah aplikasi manajemen keuangan modern yang dibangun dengan *Clean Architecture* dan fitur *power user* seperti analisis grafik, budgeting ketat, serta kustomisasi tampilan mendalam.

Aplikasi ini membantu pengguna melacak pemasukan/pengeluaran, menyimpan untuk tujuan tertentu (*Saving Goals*), dan menjaga kesehatan finansial tanpa ribet.

---

## ✨ Fitur Unggulan

### 📊 1. Manajemen Transaksi & Analisis
- **Pencatatan Cepat:** Catat pemasukan dan pengeluaran dengan kategori kustom.
- **Filter Canggih:** Harian, Mingguan, Bulanan, dan Tahunan.
- **Visualisasi Data:** Pie chart interaktif untuk melihat kategori terbesar.

### 🎯 2. Budgeting & Celengan Digital
- **Budget Control:** Set batas pengeluaran per kategori dengan progress bar *real-time*.
- **Saving Goals:** Buat target tabungan (misal: “Beli PS5”), atur deadline, dan cek progres otomatis.

### 🎨 3. Kustomisasi Tingkat Tinggi (Chameleon Mode)
- **Tema Gelap & Terang**
- **Custom Background:** Warna solid atau gambar galeri.
- **Smart Contrast:** Teks otomatis menyesuaikan supaya tetap terbaca.

### 💾 4. Keamanan & Data
- **Local Only:** Semua data disimpan aman di perangkat menggunakan SQLite (Drift).
- **Backup & Restore CSV**
- **Profile Picture:** Dengan cropping presisi menggunakan `image_cropper`.

---

## 📸 Screenshots

| Beranda (Custom BG) | Analisis Grafik | Celengan Digital | Dark Mode |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/home.png" width="200"> | <img src="screenshots/graph.png" width="200"> | <img src="screenshots/goal.png" width="200"> | <img src="screenshots/dark.png" width="200"> |

---

## 🛠️ Teknologi yang Digunakan

Project ini mengikuti *best practice* Flutter:

- **Framework:** Flutter & Dart (Java 17 compatible)
- **Architecture:** Feature-first + Clean Architecture
- **State Management:** `flutter_bloc`
- **Database:** `drift` (SQLite, reactive, type-safe)
- **Charting:** `fl_chart`
- **Image Handling:**
  - `image_picker`
  - `image_cropper`
- **Utilities:**
  - `csv` (backup/restore)
  - `shared_preferences`
  - `intl`, `table_calendar`

---

## 🚀 Cara Install & Menjalankan

1. **Clone Repository**
    ```bash
    git clone https://github.com/username/cashwise.git
    cd cashwise
    ```

2. **Install Dependencies**
    ```bash
    flutter pub get
    ```

3. **Setup Lingkungan (Penting)**
    - Pastikan pakai **Java 17**.
    - Jika error:
      ```bash
      flutter clean
      ```

4. **Jalankan Aplikasi**
    ```bash
    flutter run
    # Atau:
    flutter run --release
    ```

---

## 📂 Struktur Folder

```text
lib/
├── core/            # Konstanta, error handling, utils
├── data/            # Drift database, repository backup
├── features/        # Modular feature
│   ├── budgeting/
│   ├── category/
│   ├── profile/
│   ├── saving_goal/
│   └── transaction/
├── presentation/    # UI, pages, theme
└── main.dart        # Entry point & Dependency Injection

🤝 Kontribusi

Kontribusi sangat dipersilakan!

Fork repository

Buat branch:
git checkout -b fitur-keren

Commit:
git commit -m "Menambahkan fitur keren"

Push:
git push origin fitur-keren

Buka Pull Request
