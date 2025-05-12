import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final DatabaseHelper _databaseHelper;

  AssetRepositoryImpl(this._databaseHelper);

  // จัดการสินทรัพย์
  @override
  Future<List<Asset>> getAssets() async {
    final assetsMaps = await _databaseHelper.getAssets();
    return assetsMaps.map((map) => AssetModel.fromMap(map)).toList();
  }

  // เปลี่ยนชื่อจาก getAssetByUid เป็น findAssetByUid ให้ตรงกับที่เรียกใช้ในโค้ด
  @override
  Future<Asset?> findAssetByUid(String uid) async {
    // เปลี่ยนชื่อจาก getAssetByUid เป็น findAssetByUid ให้ตรงกับที่เรียกใช้
    final assetMap = await _databaseHelper.getAssetByUid(uid);
    if (assetMap == null) return null;
    return AssetModel.fromMap(assetMap);
  }

  // เพิ่มเมธอด getAssetByUid เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> getAssetByUid(String uid) async {
    return findAssetByUid(uid); // เรียกใช้เมธอด findAssetByUid ที่มีอยู่แล้ว
  }

  @override
  Future<bool> updateAssetStatus(String uid, String status) async {
    return await _databaseHelper.updateStatus(uid, status);
  }

  // เพิ่มเมธอด updateAsset เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> updateAsset(Asset asset) async {
    // แปลง Asset เป็น AssetModel
    final assetModel = asset as AssetModel;

    // อัปเดตสถานะในฐานข้อมูล
    bool success = await _databaseHelper.updateAsset(
      assetModel.uid,
      assetModel.id,
      assetModel.category,
      assetModel.brand,
      assetModel.department,
      assetModel.status,
      assetModel.date,
    );

    if (success) {
      return asset;
    }
    return null;
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    final assetModel = asset as AssetModel;
    await _databaseHelper.insertNewAsset(
      assetModel.id,
      assetModel.category,
      assetModel.brand,
      assetModel.department,
      assetModel.uid,
      assetModel.date,
    );
  }

  @override
  Future<void> deleteAsset(String uid) async {
    await _databaseHelper.deleteAssetByUid(uid);
  }

  @override
  Future<void> deleteAllAssets() async {
    await _databaseHelper.deleteAllAssets();
  }

  // จัดการหมวดหมู่
  @override
  Future<List<String>> getCategories() async {
    return await _databaseHelper.getCategories();
  }

  @override
  Future<void> addCategory(String name) async {
    await _databaseHelper.addCategory(name);
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    await _databaseHelper.updateCategory(oldName, newName);
  }

  @override
  Future<void> deleteCategory(String name) async {
    await _databaseHelper.deleteCategory(name);
  }

  // จัดการแผนก
  @override
  Future<List<String>> getDepartments() async {
    return await _databaseHelper.getDepartments();
  }

  @override
  Future<void> addDepartment(String name) async {
    await _databaseHelper.addDepartment(name);
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    await _databaseHelper.updateDepartment(oldName, newName);
  }

  @override
  Future<void> deleteDepartment(String name) async {
    await _databaseHelper.deleteDepartment(name);
  }

  // เพิ่มเมธอด getRandomUid เพื่อสุ่ม UID จากฐานข้อมูล
  @override
  Future<String?> getRandomUid() async {
    try {
      // เรียกใช้เมธอด getRandomUid ที่อยู่ใน DatabaseHelper แทน getRandomAsset
      return await _databaseHelper.getRandomUid();
    } catch (e) {
      print('Error in getRandomUid: ${e.toString()}');
      return null;
    }
  }
}
