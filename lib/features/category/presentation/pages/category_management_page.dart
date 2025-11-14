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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Manajemen Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
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
                
                return Dismissible(
                  key: ValueKey(category.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  onDismissed: (direction) {
                    context.read<CategoryBloc>().add(DeleteCategoryEvent(category.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${category.name} telah dihapus.'),
                        backgroundColor: Colors.red.shade700,
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
                              // Kirim kategori yang mau diedit
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
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}