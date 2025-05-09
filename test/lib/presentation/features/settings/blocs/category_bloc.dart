import 'package:flutter/material.dart';
import 'package:rfid_project/domain/usecases/cartegory/add_category_usecase.dart'; // สะกดผิด ควรเป็น category
import 'package:rfid_project/domain/usecases/cartegory/delete_category_usecase.dart'; // สะกดผิด ควรเป็น category
import 'package:rfid_project/domain/usecases/cartegory/get_categories_usecase.dart'; // สะกดผิด ควรเป็น category
import 'package:rfid_project/domain/usecases/cartegory/update_category_usecase.dart'; // สะกดผิด ควรเป็น category

enum CategoryStatus { initial, loading, loaded, error }

class CategoryBloc extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoryStatus _status = CategoryStatus.initial;
  List<String> _categories = [];
  String _errorMessage = '';

  CategoryBloc(
    this._getCategoriesUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  );

  CategoryStatus get status => _status;
  List<String> get categories => _categories;
  String get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _status = CategoryStatus.loading;
    notifyListeners();

    try {
      final categories = await _getCategoriesUseCase.execute();
      _categories = categories;
      _status = CategoryStatus.loaded;
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    _status = CategoryStatus.loading;
    notifyListeners();

    try {
      await _addCategoryUseCase.execute(name);
      await loadCategories();
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(String oldName, String newName) async {
    _status = CategoryStatus.loading;
    notifyListeners();

    try {
      await _updateCategoryUseCase.execute(oldName, newName);
      await loadCategories();
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String name) async {
    _status = CategoryStatus.loading;
    notifyListeners();

    try {
      await _deleteCategoryUseCase.execute(name);
      await loadCategories();
    } catch (e) {
      _status = CategoryStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
