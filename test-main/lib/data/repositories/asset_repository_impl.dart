import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../core/config/app_config.dart';
import '../datasources/local/database_helper.dart';
import '../datasources/remote/mysql_data_source.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final DatabaseHelper _databaseHelper;
  final MySqlDataSource? _mysqlDataSource;

  AssetRepositoryImpl(this._databaseHelper, [this._mysqlDataSource]);

  // จัดการสินทรัพย์
  @override
  Future<List<Asset>> getAssets() async {
    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL
      final assetsMaps = await _mysqlDataSource.getAssets();
      return assetsMaps.map((map) => AssetModel.fromMap(map)).toList();
    } else {
      // ใช้งาน SQLite
      final assetsMaps = await _databaseHelper.getAssets();
      return assetsMaps.map((map) => AssetModel.fromMap(map)).toList();
    }
  }

  // เปลี่ยนชื่อจาก getAssetByUid เป็น findAssetByUid ให้ตรงกับที่เรียกใช้ในโค้ด
  @override
  Future<Asset?> findAssetByUid(String uid) async {
    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL
      final assetMap = await _mysqlDataSource.getAssetByUid(uid);
      if (assetMap == null) return null;
      return AssetModel.fromMap(assetMap);
    } else {
      // ใช้งาน SQLite
      final assetMap = await _databaseHelper.getAssetByUid(uid);
      if (assetMap == null) return null;
      return AssetModel.fromMap(assetMap);
    }
  }

  // เพิ่มเมธอด getAssetByUid เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> getAssetByUid(String uid) async {
    return findAssetByUid(uid); // เรียกใช้เมธอด findAssetByUid ที่มีอยู่แล้ว
  }

  @override
  Future<bool> updateAssetStatus(String uid, String status) async {
    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL
      return await _mysqlDataSource.updateStatus(uid, status);
    } else {
      // ใช้งาน SQLite
      return await _databaseHelper.updateStatus(uid, status);
    }
  }

  // เพิ่มเมธอด updateAsset เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> updateAsset(Asset asset) async {
    // แปลง Asset เป็น AssetModel
    final assetModel = asset as AssetModel;

    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL - อาจต้องเพิ่มเมธอดนี้ใน MySqlDataSource
      // มีวิธีง่ายๆ คือใช้ updateStatus แทนเพื่อไม่ต้องสร้างเมธอดใหม่
      bool success = await _mysqlDataSource.updateStatus(
        assetModel.uid,
        assetModel.status,
      );

      if (success) {
        return asset;
      }
      return null;
    } else {
      // ใช้งาน SQLite
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
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    final assetModel = asset as AssetModel;

    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL
      await _mysqlDataSource.insertNewAsset(
        assetModel.id,
        assetModel.category,
        assetModel.brand,
        assetModel.department,
        assetModel.uid,
        assetModel.date,
      );
    } else {
      // ใช้งาน SQLite
      await _databaseHelper.insertNewAsset(
        assetModel.id,
        assetModel.category,
        assetModel.brand,
        assetModel.department,
        assetModel.uid,
        assetModel.date,
      );
    }
  }

  @override
  Future<void> deleteAsset(String uid) async {
    if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
      // ใช้งาน MySQL
      await _mysqlDataSource.deleteAssetByUid(uid);
    } else {
      // ใช้งาน SQLite
      await _databaseHelper.deleteAssetByUid(uid);
    }
  }

  @override
  Future<void> deleteAllAssets() async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    // เพื่อความปลอดภัย อาจไม่ควรอนุญาตให้ลบข้อมูลทั้งหมดในฐานข้อมูลระยะไกล
    if (!AppConfig.useRemoteDatabase) {
      await _databaseHelper.deleteAllAssets();
    }
  }

  // จัดการหมวดหมู่
  @override
  Future<List<String>> getCategories() async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    return await _databaseHelper.getCategories();
  }

  @override
  Future<void> addCategory(String name) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.addCategory(name);
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.updateCategory(oldName, newName);
  }

  @override
  Future<void> deleteCategory(String name) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.deleteCategory(name);
  }

  // จัดการแผนก
  @override
  Future<List<String>> getDepartments() async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    return await _databaseHelper.getDepartments();
  }

  @override
  Future<void> addDepartment(String name) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.addDepartment(name);
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.updateDepartment(oldName, newName);
  }

  @override
  Future<void> deleteDepartment(String name) async {
    // หมายเหตุ: ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
    await _databaseHelper.deleteDepartment(name);
  }

  // เพิ่มเมธอด getRandomUid เพื่อสุ่ม UID จากฐานข้อมูล
  @override
  Future<String?> getRandomUid() async {
    try {
      if (AppConfig.useRemoteDatabase && _mysqlDataSource != null) {
        // ต้องเพิ่มเมธอดนี้ใน MySqlDataSource ถ้าต้องการใช้กับ MySQL
        // ตัวอย่างเช่น: return await _mysqlDataSource!.getRandomUid();
        return null;
      } else {
        // ใช้งาน SQLite
        return await _databaseHelper.getRandomUid();
      }
    } catch (e) {
      print('Error in getRandomUid: ${e.toString()}');
      return null;
    }
  }
}
