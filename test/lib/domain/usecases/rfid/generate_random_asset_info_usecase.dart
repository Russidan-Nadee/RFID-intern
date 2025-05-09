import 'package:rfid_project/domain/entities/random_asset_info.dart';

import '../../repositories/random_asset_repository.dart';

class GenerateRandomAssetInfoUseCase {
  final RandomAssetRepository _repository;

  GenerateRandomAssetInfoUseCase(this._repository);

  Future<RandomAssetInfo> execute() async {
    return await _repository.generateRandomAssetInfo();
  }
}
