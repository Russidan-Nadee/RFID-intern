import 'package:rfid_project/domain/repositories/asset_repository.dart';

class UpdateCategoryUseCase {
  final AssetRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> execute(String oldName, String newName) async {
    await repository.updateCategory(oldName, newName);
  }
}
