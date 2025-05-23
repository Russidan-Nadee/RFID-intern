import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';

class GetAssetsUseCase {
  final AssetRepository repository;

  GetAssetsUseCase(this.repository);

  Future<List<Asset>> execute() async {
    return await repository.getAssets();
  }
}
