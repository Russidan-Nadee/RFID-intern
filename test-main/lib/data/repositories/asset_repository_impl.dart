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
        'id': map['id'] ?? map['itemId'] ?? '',
        'uid': map['guid'] ?? map['epc'] ?? '',
        'category': map['category'] ?? '',
        'status': map['status'] ?? '',
        'brand': map['itemName'] ?? '',
        'department': map['currentLocation'] ?? '',
        'date': map['lastScanTime'] ?? '',
      };
      return AssetModel.fromMap(assetMap);
    }).toList();
  }

  @override
  Future<Asset?> findAssetByUid(String uid) async {
    final assetData = await _apiService.getAssetByUid(uid);
    if (assetData == null) return null;

    // แปลงข้อมูลจาก API เป็นรูปแบบที่ frontend ใช้
    final assetMap = {
      'id': assetData['itemId'] ?? '',
      'uid': assetData['guid'] ?? assetData['epc'] ?? '',
      'category': assetData['category'] ?? '',
      'status': assetData['status'] ?? '',
      'brand': assetData['itemName'] ?? '',
      'department': assetData['currentLocation'] ?? '',
      'date': assetData['lastScanTime'] ?? '',
    };

    return AssetModel.fromMap(assetMap);
  }

  @override
  Future<Asset?> getAssetByUid(String uid) async {
    return findAssetByUid(uid);
  }

  @override
  Future<bool> updateAssetStatus(String uid, String status) async {
    return await _apiService.updateAssetStatus(uid, status);
  }

  @override
  Future<Asset?> updateAsset(Asset asset) async {
    final assetModel = asset as AssetModel;
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
    final assetData = {
      'itemId': assetModel.id,
      'guid': assetModel.uid,
      'category': assetModel.category,
      'itemName': assetModel.brand,
      'currentLocation': assetModel.department,
      'status': assetModel.status,
      'lastScanTime': assetModel.date,
    };
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

  // เพิ่ม method ที่หายไป
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

  @override
  Future<List<String>> getDepartments() async {
    // ถ้ายังไม่มี method นี้ใน ApiService ให้สร้างเพิ่ม
    try {
      return await _apiService.getDepartments();
    } catch (e) {
      return ['Production', 'Warehouse', 'Office']; // ค่าเริ่มต้น
    }
  }

  @override
  Future<void> addDepartment(String name) async {
    // ถ้ายังไม่มี method นี้ใน ApiService ให้สร้างเพิ่ม
    try {
      await _apiService.addDepartment(name);
    } catch (e) {
      print('Error adding department: $e');
    }
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    // ถ้ายังไม่มี method นี้ใน ApiService ให้สร้างเพิ่ม
    try {
      await _apiService.updateDepartment(oldName, newName);
    } catch (e) {
      print('Error updating department: $e');
    }
  }

  @override
  Future<void> deleteDepartment(String name) async {
    // ถ้ายังไม่มี method นี้ใน ApiService ให้สร้างเพิ่ม
    try {
      await _apiService.deleteDepartment(name);
    } catch (e) {
      print('Error deleting department: $e');
    }
  }

  @override
  Future<String?> getRandomUid() async {
    try {
      final assets = await getAssets();
      if (assets.isEmpty) return null;
      final random =
          assets[(DateTime.now().millisecondsSinceEpoch % assets.length)];
      return random.uid;
    } catch (e) {
      return null;
    }
  }
}
