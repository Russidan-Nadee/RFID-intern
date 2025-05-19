import 'dart:io';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/asset_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiService _apiService;

  AssetRepositoryImpl(this._apiService);

  @override
  Future<Asset?> findAssetByTagId(String tagId) async {
    final assetData = await _apiService.getAssetByUid(
      tagId,
    ); // ใช้ API ที่มีอยู่แล้ว
    if (assetData == null) return null;

    // ส่งข้อมูลทั้งหมดจาก API ไปยัง AssetModel
    return AssetModel.fromMap(assetData);
  }

  // จัดการสินทรัพย์
  @override
  Future<List<Asset>> getAssets() async {
    final assetsData = await _apiService.getAssets();
    return assetsData.map((map) {
      // ส่งข้อมูลทั้งหมดจาก API ไปยัง AssetModel
      return AssetModel.fromMap(map);
    }).toList();
  }

  // เพิ่มเมธอดใหม่เพื่อดึงข้อมูลดิบทั้งหมด
  @override
  Future<Map<String, dynamic>?> getRawAssetData(String uid) async {
    try {
      return await _apiService.getAssetByUid(uid);
    } catch (e) {
      print('Error getting raw asset data: $e');
      rethrow;
    }
  }

  @override
  Future<Asset?> findAssetByUid(String uid) async {
    final assetData = await _apiService.getAssetByUid(uid);
    if (assetData == null) return null;

    // ส่งข้อมูลทั้งหมดจาก API ไปยัง AssetModel
    return AssetModel.fromMap(assetData);
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
    // แก้ไขการเรียกใช้ uid และ status เป็น tagId และ status
    final success = await _apiService.updateAssetStatus(
      assetModel.tagId,
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
    final assetData = assetModel.toMap();
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
      return ['Production', 'Warehouse', 'Office']; // ค่าเริ่มต้น
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
  Future<String?> getRandomUid() async {
    try {
      final assets = await getAssets();
      if (assets.isEmpty) return null;
      final random =
          assets[(DateTime.now().millisecondsSinceEpoch % assets.length)];
      // แก้ไขการเรียกใช้ uid เป็น tagId
      return random.tagId;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> exportAssetsToCSV(
    List<Asset> assets,
    List<String> columns,
  ) async {
    try {
      // สร้างข้อมูล CSV
      List<List<dynamic>> rows = [];
      rows.add(columns);
      for (var asset in assets) {
        List<dynamic> row = [];

        // ใช้ for loop แทนเพื่อรองรับทุกคอลัมน์ที่อาจถูกเลือก
        for (var column in columns) {
          var value;

          // แมปคอลัมน์ในตาราง MySQL
          switch (column) {
            case 'ID':
              value = asset.id;
              break;
            case 'Item ID':
              value = asset.itemId;
              break;
            case 'Tag ID':
              value = asset.tagId;
              break;
            case 'EPC':
              value = asset.epc;
              break;
            case 'Item Name':
              value = asset.itemName;
              break;
            case 'Category':
              value = asset.category;
              break;
            case 'Status':
              value = asset.status;
              break;
            case 'Tag Type':
              value = asset.tagType;
              break;
            case 'Sale Date':
              value = asset.saleDate;
              break;
            case 'Frequency':
              value = asset.frequency;
              break;
            case 'Current Location':
              value = asset.currentLocation;
              break;
            case 'Zone':
              value = asset.zone;
              break;
            case 'Last Scan Time':
              value = asset.lastScanTime;
              break;
            case 'Last Scanned By':
              value = asset.lastScannedBy;
              break;
            case 'Battery Level':
              value = asset.batteryLevel;
              break;
            case 'Batch Number':
              value = asset.batchNumber;
              break;
            case 'Manufacturing Date':
              value = asset.manufacturingDate;
              break;
            case 'Expiry Date':
              value = asset.expiryDate;
              break;
            case 'Value':
              value = asset.value;
              break;
            default:
              value = '';
              break;
          }

          row.add(value);
        }

        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // สร้างชื่อไฟล์
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';
      final filename = 'assets_export_$timestamp.csv';

      // บันทึกไฟล์ในพื้นที่แคชของแอพ
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsString(csv);

      return path;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return null;
    }
  }

  @override
  Future<Asset?> findAssetByEpc(String epc) async {
    try {
      // ดึงสินทรัพย์ทั้งหมด
      final assets = await getAssets();

      // หาสินทรัพย์ที่มี EPC ตรงกับที่ต้องการ
      for (var asset in assets) {
        if (asset.epc.trim() == epc.trim()) {
          return asset;
        }
      }

      // ถ้าไม่พบ
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
      return await _apiService.createAsset(assetData);
    } catch (e) {
      print('Error creating asset: $e');
      return false;
    }
  }
}
