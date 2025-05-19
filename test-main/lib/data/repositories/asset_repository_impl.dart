// data/repositories/asset_repository_impl.dart
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiService _apiService;

  AssetRepositoryImpl(this._apiService);

  @override
  Future<Asset?> findAssetBytagId(String tagId) async {
    final assetData = await _apiService.getAssetBytagId(tagId);
    if (assetData == null) return null;
    return AssetModel.fromMap(assetData);
  }

  @override
  Future<List<Asset>> getAssets() async {
    final assetsData = await _apiService.getAssets();
    return assetsData.map((map) => AssetModel.fromMap(map)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getRawAssetData(String tagId) async {
    try {
      print('AssetRepositoryImpl - getRawAssetData with tagId: $tagId');
      return await _apiService.getAssetBytagId(tagId);
    } catch (e) {
      print('Error getting raw asset data: $e');
      rethrow;
    }
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    final assetModel = asset as AssetModel;
    await _apiService.insertAsset(assetModel.toMap());
  }

  @override
  Future<void> deleteAllAssets() async {
    await _apiService.deleteAllAssets();
  }

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
    try {
      return await _apiService.getDepartments();
    } catch (e) {
      return ['Production', 'Warehouse', 'Office'];
    }
  }

  @override
  Future<void> addDepartment(String name) async {
    try {
      await _apiService.addDepartment(name);
    } catch (e) {
      print('Error adding department: $e');
    }
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      await _apiService.updateDepartment(oldName, newName);
    } catch (e) {
      print('Error updating department: $e');
    }
  }

  @override
  Future<void> deleteDepartment(String name) async {
    try {
      await _apiService.deleteDepartment(name);
    } catch (e) {
      print('Error deleting department: $e');
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
      print('Error finding asset by EPC: $e');
      return null;
    }
  }

  @override
  Future<bool> checkEpcExists(String epc) async {
    try {
      final asset = await findAssetByEpc(epc);
      return asset != null;
    } catch (e) {
      print('Error checking EPC existence: $e');
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
      print('Error creating asset: $e');
      return false;
    }
  }

  @override
  Future<Asset?> updateAsset(Asset asset) async {
    // Add implementation if needed
    return null;
  }

  @override
  Future<String?> exportAssetsToCSV(
    List<Asset> assets,
    List<String> columns,
  ) async {
    // Add implementation if needed
    return null;
  }
}
