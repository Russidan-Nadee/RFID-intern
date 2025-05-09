import 'package:rfid_project/domain/repositories/asset_repository.dart';

class DeleteCategoryUseCase {
  final AssetRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> execute(String name) async {
    await repository.deleteCategory(name);
  }
}
