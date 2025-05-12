import '../entities/asset.dart';

abstract class AssetRepository {
  // จัดการสินทรัพย์
  Future<List<Asset>> getAssets();
  Future<Asset?> getAssetByUid(String uid);
  Future<bool> updateAssetStatus(String uid, String status);
  Future<void> insertAsset(Asset asset);
  Future<void> deleteAsset(String uid);
  Future<void> deleteAllAssets();
  Future<Asset?> findAssetByUid(String uid);
  Future<Asset?> updateAsset(Asset asset);
  // เพิ่มเมธอดสำหรับการสุ่ม UID
  Future<String?> getRandomUid();

  // จัดการหมวดหมู่
  Future<List<String>> getCategories();
  Future<void> addCategory(String name);
  Future<void> updateCategory(String oldName, String newName);
  Future<void> deleteCategory(String name);

  // จัดการแผนก
  Future<List<String>> getDepartments();
  Future<void> addDepartment(String name);
  Future<void> updateDepartment(String oldName, String newName);
  Future<void> deleteDepartment(String name);
}
