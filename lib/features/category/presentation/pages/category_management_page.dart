// lib/features/category/presentation/pages/category_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:cashwise/features/category/presentation/pages/add_category_page.dart';
import 'package:cashwise/features/category/presentation/widgets/category_list_item.dart';
import 'package:cashwise/presentation/widgets/common/loading_indicator.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchAllCategories());
  }

  @override
  Widget build(BuildContext context) {
    // --- REFAKTOR: Ambil theme ---
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;

    return Scaffold(
      // --- REFAKTOR: Hapus 'backgroundColor' ---
      appBar: AppBar(
        title: const Text('Manajemen Kategori',
            style: TextStyle(fontWeight: FontWeight.bold)),
        // --- REFAKTOR: Hapus semua styling, biarin AppBarTheme ---
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const LoadingIndicator();
          } else if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(child: Text('Belum ada kategori.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];

                // --- REFAKTOR: Bikin warna semantik (delete) jadi theme-aware ---
                final Color deleteColor =
                    isLightMode ? Colors.red.shade600 : Colors.red.shade400;
                final Color snackBarColor =
                    isLightMode ? Colors.red.shade700 : Colors.red.shade500;

                return Dismissible(
                  key: ValueKey(category.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      // --- REFAKTOR: Pake warna delete yg theme-aware ---
                      color: deleteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 28),
                  ),
                  onDismissed: (direction) {
                    context
                        .read<CategoryBloc>()
                        .add(DeleteCategoryEvent(category.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${category.name} telah dihapus.'),
                        // --- REFAKTOR: Pake warna snackbar yg theme-aware ---
                        backgroundColor: snackBarColor,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: CategoryListItem(
                      category: category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCategoryPage(
                              categoryToEdit: category,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (state is CategoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCategoryPage()),
          );
        },
        // (Ini SEMANTIK, biarin. Aksi "Tambah" = Teal)
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}