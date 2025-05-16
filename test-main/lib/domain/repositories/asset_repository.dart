import '../entities/asset.dart';

abstract class AssetRepository {
  Future<List<Asset>> getAssets();
  Future<Asset?> getAssetByUid(String uid);
  Future<bool> updateAssetStatus(String uid, String status);
  Future<void> insertAsset(Asset asset);
  Future<void> deleteAsset(String uid);
  Future<void> deleteAllAssets();
  Future<Asset?> findAssetByUid(String uid);
  Future<Asset?> findAssetByTagId(String tagId); // เพิ่มเมธอดใหม่นี้
  Future<Asset?> updateAsset(Asset asset);
  Future<String?> getRandomUid();
  Future<String?> exportAssetsToCSV(List<Asset> assets, List<String> columns);
  Future<Map<String, dynamic>?> getRawAssetData(String uid);
  Future<List<String>> getCategories();
  Future<void> addCategory(String name);
  Future<void> updateCategory(String oldName, String newName);
  Future<void> deleteCategory(String name);
  Future<List<String>> getDepartments();
  Future<void> addDepartment(String name);
  Future<void> updateDepartment(String oldName, String newName);
  Future<void> deleteDepartment(String name);
}
