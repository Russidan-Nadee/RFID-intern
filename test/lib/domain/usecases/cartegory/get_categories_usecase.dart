import 'package:rfid_project/domain/repositories/asset_repository.dart';

class GetCategoriesUseCase {
  final AssetRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<String>> execute() async {
    return await repository.getCategories();
  }
}
