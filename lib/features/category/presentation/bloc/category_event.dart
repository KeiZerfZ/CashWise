import 'package:equatable/equatable.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object> get props => [];
}

class FetchAllCategories extends CategoryEvent {}
class AddCategoryEvent extends CategoryEvent {
  final Category category;
  const AddCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}