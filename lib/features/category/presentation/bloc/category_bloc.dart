import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/usecases/add_category.dart';
import 'package:cashwise/features/category/domain/usecases/get_all_categories.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategories getAllCategories;
  final AddCategory addCategory;

  CategoryBloc({required this.getAllCategories, required this.addCategory}) : super(CategoryInitial()) {
    on<FetchAllCategories>(_onFetchAllCategories);
    on<AddCategoryEvent>(_onAddCategory);
  }

  void _onFetchAllCategories(FetchAllCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final result = await getAllCategories(NoParams());
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  void _onAddCategory(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await addCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(FetchAllCategories()),
    );
  }
}