// test/features/category/presentation/bloc/category_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/category/domain/entities/category.dart';
import 'package:cashwise/features/category/domain/usecases/add_category.dart';
import 'package:cashwise/features/category/domain/usecases/get_all_categories.dart';
import 'package:cashwise/features/category/presentation/bloc/category_bloc.dart';
import 'package:cashwise/features/category/presentation/bloc/category_event.dart';
import 'package:cashwise/features/category/presentation/bloc/category_state.dart';
import 'package:flutter/material.dart';

class MockGetAllCategories extends Mock implements GetAllCategories {}
class MockAddCategory extends Mock implements AddCategory {}

void main() {
  late MockGetAllCategories mockGetAllCategories;
  late MockAddCategory mockAddCategory;
  late CategoryBloc categoryBloc;

  final tCategoryList = [
    const Category(id: 1, name: 'Makanan', color: Colors.red, iconName: 'fastfood'),
  ];

  setUp(() {
    mockGetAllCategories = MockGetAllCategories();
    mockAddCategory = MockAddCategory();
    categoryBloc = CategoryBloc(
      getAllCategories: mockGetAllCategories,
      addCategory: mockAddCategory,
    );
  });

  test('initial state should be CategoryInitial', () {
    expect(categoryBloc.state, CategoryInitial());
  });

  group('FetchAllCategories', () {
    blocTest<CategoryBloc, CategoryState>(
      'should emit [CategoryLoading, CategoryLoaded] when data is gotten successfully',
      build: () {
        // ===== PERBAIKANNYA DI SINI =====
        // Ganti 'any()' dengan 'NoParams()' yang lebih spesifik
        when(() => mockGetAllCategories(NoParams()))
            .thenAnswer((_) async => Right(tCategoryList));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(FetchAllCategories()),
      expect: () => [
        CategoryLoading(),
        CategoryLoaded(tCategoryList),
      ],
      verify: (_) {
        verify(() => mockGetAllCategories(NoParams())).called(1);
      },
    );
  });
}