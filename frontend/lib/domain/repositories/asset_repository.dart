// domain/repositories/asset_repository.dart
import '../entities/asset.dart';

abstract class AssetRepository {
  Future<List<Asset>> getAssets();
  Future<Map<String, dynamic>?> getRawAssetData(String tagId);
  Future<void> insertAsset(Asset asset);
  Future<void> deleteAllAssets();
  Future<Asset?> findAssetBytagId(String tagId);
  Future<Asset?> updateAsset(Asset asset);
  Future<String?> exportAssetsToCSV(List<Asset> assets, List<String> columns);
  Future<List<String>> getCategories();
  Future<void> addCategory(String name);
  Future<void> updateCategory(String oldName, String newName);
  Future<void> deleteCategory(String name);
  Future<List<String>> getDepartments();
  Future<void> addDepartment(String name);
  Future<void> updateDepartment(String oldName, String newName);
  Future<void> deleteDepartment(String name);
  Future<Asset?> findAssetByEpc(String epc);
  Future<bool> checkEpcExists(String epc);
  Future<bool> createAsset(Asset asset);
  Future<bool> updateAssetStatusToChecked(
    String tagId, {
    String? lastScannedBy,
  });
}
