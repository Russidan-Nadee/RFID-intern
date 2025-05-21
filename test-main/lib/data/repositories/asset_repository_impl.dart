// data/repositories/asset_repository_impl.dart
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/asset_model.dart';
import '../../core/exceptions/app_exceptions.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiService _apiService;

  AssetRepositoryImpl(this._apiService);

  @override
  Future<Asset?> findAssetBytagId(String tagId) async {
    try {
      final assetData = await _apiService.getAssetBytagId(tagId);
      if (assetData == null) return null;
      return AssetModel.fromMap(assetData);
    } catch (e) {
      // เพิ่ม log แต่ยัง throw exception
      print('DEBUG - Error finding asset by tagId: $e');
      throw DatabaseException('Error finding asset by tagId: $e');
    }
  }

  @override
  Future<List<Asset>> getAssets() async {
    try {
      final assetsData = await _apiService.getAssets();
      return assetsData.map((map) => AssetModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG - Error getting all assets: $e');
      throw DatabaseException('Error getting all assets: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getRawAssetData(String tagId) async {
    try {
      print('DEBUG - AssetRepositoryImpl - getRawAssetData with tagId: $tagId');
      return await _apiService.getAssetBytagId(tagId);
    } catch (e) {
      print('DEBUG - Error getting raw asset data: $e');
      throw DatabaseException('Error getting raw asset data: $e');
    }
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    try {
      final assetModel = asset as AssetModel;
      await _apiService.insertAsset(assetModel.toMap());
    } catch (e) {
      print('DEBUG - Error inserting asset: $e');
      throw DatabaseException('Error inserting asset: $e');
    }
  }

  @override
  Future<void> deleteAllAssets() async {
    try {
      await _apiService.deleteAllAssets();
    } catch (e) {
      print('DEBUG - Error deleting all assets: $e');
      throw DatabaseException('Error deleting all assets: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      print('DEBUG - Error getting categories: $e');
      throw DatabaseException('Error getting categories: $e');
    }
  }

  @override
  Future<void> addCategory(String name) async {
    try {
      await _apiService.addCategory(name);
    } catch (e) {
      print('DEBUG - Error adding category: $e');
      throw DatabaseException('Error adding category: $e');
    }
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    try {
      await _apiService.updateCategory(oldName, newName);
    } catch (e) {
      print('DEBUG - Error updating category: $e');
      throw DatabaseException('Error updating category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String name) async {
    try {
      await _apiService.deleteCategory(name);
    } catch (e) {
      print('DEBUG - Error deleting category: $e');
      throw DatabaseException('Error deleting category: $e');
    }
  }

  @override
  Future<List<String>> getDepartments() async {
    try {
      return await _apiService.getDepartments();
    } catch (e) {
      // ยังคง fallback ให้ทำงานได้เหมือนเดิม
      print('DEBUG - Error getting departments, using fallback values: $e');
      return ['Production', 'Warehouse', 'Office'];
    }
  }

  @override
  Future<void> addDepartment(String name) async {
    try {
      await _apiService.addDepartment(name);
    } catch (e) {
      print('DEBUG - Error adding department: $e');
      throw DatabaseException('Error adding department: $e');
    }
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      await _apiService.updateDepartment(oldName, newName);
    } catch (e) {
      print('DEBUG - Error updating department: $e');
      throw DatabaseException('Error updating department: $e');
    }
  }

  @override
  Future<void> deleteDepartment(String name) async {
    try {
      await _apiService.deleteDepartment(name);
    } catch (e) {
      print('DEBUG - Error deleting department: $e');
      throw DatabaseException('Error deleting department: $e');
    }
  }

  @override
  Future<Asset?> findAssetByEpc(String epc) async {
    try {
      final assets = await getAssets();
      for (var asset in assets) {
        if (asset.epc.trim() == epc.trim()) {
          return asset;
        }
      }
      return null;
    } catch (e) {
      print('DEBUG - Error finding asset by EPC: $e');
      // ส่ง null กลับเหมือนเดิมเพื่อให้โค้ดทำงานได้แบบเดิม
      // แต่ยัง throw exception เพื่อการจัดการที่ดีขึ้น
      throw DatabaseException('Error finding asset by EPC: $e');
    }
  }

  @override
  Future<bool> checkEpcExists(String epc) async {
    try {
      final asset = await findAssetByEpc(epc);
      return asset != null;
    } catch (e) {
      print('DEBUG - Error checking EPC existence: $e');
      // คืนค่า false เหมือนเดิม
      return false;
    }
  }

  @override
  Future<bool> createAsset(Asset asset) async {
    try {
      final assetModel = asset as AssetModel;
      final assetData = assetModel.toMap();

      if (assetData['batteryLevel'] == '') {
        assetData['batteryLevel'] = '0';
      }

      if (assetData['value'] == '') {
        assetData['value'] = '0';
      }

      return await _apiService.createAsset(assetData);
    } catch (e) {
      print('DEBUG - Error creating asset: $e');
      // คืนค่า false เพื่อให้โค้ดทำงานได้แบบเดิม
      return false;
    }
  }

  @override
  Future<Asset?> updateAsset(Asset asset) async {
    try {
      // Add implementation if needed
      return null;
    } catch (e) {
      print('DEBUG - Error updating asset: $e');
      throw DatabaseException('Error updating asset: $e');
    }
  }

  @override
  Future<String?> exportAssetsToCSV(
    List<Asset> assets,
    List<String> columns,
  ) async {
    try {
      // Add implementation if needed
      return null;
    } catch (e) {
      print('DEBUG - Error exporting assets to CSV: $e');
      throw DatabaseException('Error exporting assets to CSV: $e');
    }
  }

  @override
  Future<bool> updateAssetStatusToChecked(
    String tagId, {
    String? lastScannedBy,
  }) async {
    try {
      print(
        'DEBUG - AssetRepositoryImpl - updateAssetStatusToChecked with tagId: $tagId, scanner: $lastScannedBy',
      );
      return await _apiService.updateAssetStatusToChecked(
        tagId,
        lastScannedBy: lastScannedBy,
      );
    } catch (e) {
      print('DEBUG - Error updating asset status: $e');
      // คืนค่า false เพื่อให้โค้ดทำงานได้แบบเดิม
      return false;
    }
  }
}
