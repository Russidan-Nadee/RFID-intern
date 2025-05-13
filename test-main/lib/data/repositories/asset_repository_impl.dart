import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiService _apiService;

  AssetRepositoryImpl(this._apiService);

  // จัดการสินทรัพย์
  @override
  Future<List<Asset>> getAssets() async {
    final assetsData = await _apiService.getAssets();
    return assetsData.map((map) {
      // แปลงข้อมูลจาก API เป็นรูปแบบที่ frontend ใช้
      final assetMap = {
        'id': map['itemId'] ?? '',
        'uid': map['guid'] ?? '',
        'category': map['category'] ?? '',
        'status': map['status'] ?? '',
        'brand': map['itemName'] ?? '',
        'department': map['department'] ?? '',
        'date': map['lastScanTime'] ?? '',
      };
      return AssetModel.fromMap(assetMap);
    }).toList();
  }

  // เปลี่ยนชื่อจาก getAssetByUid เป็น findAssetByUid ให้ตรงกับที่เรียกใช้ในโค้ด
  @override
  Future<Asset?> findAssetByUid(String uid) async {
    final assetData = await _apiService.getAssetByUid(uid);
    if (assetData == null) return null;

    // แปลงข้อมูลจาก API เป็นรูปแบบที่ frontend ใช้
    final assetMap = {
      'id': assetData['itemId'] ?? '',
      'uid': assetData['guid'] ?? '',
      'category': assetData['category'] ?? '',
      'status': assetData['status'] ?? '',
      'brand': assetData['itemName'] ?? '',
      'department': assetData['department'] ?? '',
      'date': assetData['lastScanTime'] ?? '',
    };

    return AssetModel.fromMap(assetMap);
  }

  // เพิ่มเมธอด getAssetByUid เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> getAssetByUid(String uid) async {
    return findAssetByUid(uid); // เรียกใช้เมธอด findAssetByUid ที่มีอยู่แล้ว
  }

  @override
  Future<bool> updateAssetStatus(String uid, String status) async {
    return await _apiService.updateAssetStatus(uid, status);
  }

  // เพิ่มเมธอด updateAsset เพื่อให้ตรงกับอินเตอร์เฟส
  @override
  Future<Asset?> updateAsset(Asset asset) async {
    // แปลง Asset เป็น AssetModel
    final assetModel = asset as AssetModel;

    // ส่งข้อมูลไปยัง API
    final success = await _apiService.updateAssetStatus(
      assetModel.uid,
      assetModel.status,
    );

    if (success) {
      return asset;
    }
    return null;
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    final assetModel = asset as AssetModel;

    // แปลงข้อมูลให้ตรงกับโครงสร้าง API
    final assetData = {
      'itemId': assetModel.id,
      'guid': assetModel.uid,
      'category': assetModel.category,
      'itemName': assetModel.brand,
      'department': assetModel.department,
      'status': assetModel.status,
      'lastScanTime': assetModel.date,
    };

    // ส่งข้อมูลไปยัง API
    await _apiService.insertAsset(assetData);
  }

  @override
  Future<void> deleteAsset(String uid) async {
    await _apiService.deleteAsset(uid);
  }

  @override
  Future<void> deleteAllAssets() async {
    await _apiService.deleteAllAssets();
  }

  // จัดการหมวดหมู่
  @override
  Future<List<String>> getCategories() async {
    return await _apiService.getCategories();
  }

  @override
  Future<void> addCategory(String name) async {
    await _apiService.addCategory(name);
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    await _apiService.updateCategory(oldName, newName);
  }

  @override
  Future<void> deleteCategory(String name) async {
    await _apiService.deleteCategory(name);
  }

  // จัดการแผนก
  @override
  Future<List<String>> getDepartments() async {
    return await _apiService.getDepartments();
  }

  @override
  Future<void> addDepartment(String name) async {
    await _apiService.addDepartment(name);
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    await _apiService.updateDepartment(oldName, newName);
  }

  @override
  Future<void> deleteDepartment(String name) async {
    await _apiService.deleteDepartment(name);
  }

  @override
  Future<String?> getRandomUid() async {
    try {
      final assets = await getAssets();
      if (assets.isEmpty) return null;

      // สุ่มเลือก UID จากรายการสินทรัพย์
      final random =
          assets[(DateTime.now().millisecondsSinceEpoch % assets.length)];
      return random.uid;
    } catch (e) {
      return null;
    }
  }
}
