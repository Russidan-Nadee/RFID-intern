import '../entities/random_asset_info.dart';

abstract class RandomAssetRepository {
  Future<RandomAssetInfo> generateRandomAssetInfo();
}
