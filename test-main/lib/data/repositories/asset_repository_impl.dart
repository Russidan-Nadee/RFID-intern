import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../datasources/remote/api_service.dart';
import '../models/asset_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/error_handler.dart';

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
      // การแยกประเภทข้อผิดพลาดทำให้จัดการได้ตรงจุด
      if (e is NotFoundException) {
        // กรณีไม่พบสินทรัพย์ คืนค่า null เพื่อให้ทำงานเหมือนเดิม
        return null;
      } else if (e is AppException) {
        // ส่งต่อ custom exceptions เพื่อให้ชั้นที่สูงกว่าจัดการ
        ErrorHandler.logError('Error in findAssetBytagId: ${e.toString()}');
        rethrow;
      } else {
        // แปลงข้อผิดพลาดอื่นๆ เป็น DatabaseException
        ErrorHandler.logError('Error finding asset by tagId: $e');
        throw DatabaseException('เกิดข้อผิดพลาดในการค้นหาสินทรัพย์: $e');
      }
    }
  }

  @override
  Future<List<Asset>> getAssets() async {
    try {
      final assetsData = await _apiService.getAssets();
      return assetsData.map((map) => AssetModel.fromMap(map)).toList();
    } catch (e) {
      // บันทึกข้อผิดพลาดก่อนส่งต่อ
      ErrorHandler.logError('Error in getAssets: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการดึงข้อมูลสินทรัพย์: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getRawAssetData(String tagId) async {
    try {
      ErrorHandler.logError(
        'AssetRepositoryImpl - getRawAssetData with tagId: $tagId',
      );
      return await _apiService.getAssetBytagId(tagId);
    } catch (e) {
      ErrorHandler.logError('Error getting raw asset data: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException(
        'เกิดข้อผิดพลาดในการดึงข้อมูลดิบของสินทรัพย์: $e',
      );
    }
  }

  @override
  Future<void> insertAsset(Asset asset) async {
    try {
      final assetModel = asset as AssetModel;
      await _apiService.insertAsset(assetModel.toMap());
    } catch (e) {
      ErrorHandler.logError('Error inserting asset: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการเพิ่มสินทรัพย์: $e');
    }
  }

  @override
  Future<void> deleteAllAssets() async {
    try {
      await _apiService.deleteAllAssets();
    } catch (e) {
      ErrorHandler.logError('Error deleting all assets: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการลบสินทรัพย์ทั้งหมด: $e');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      ErrorHandler.logError('Error getting categories: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการดึงข้อมูลหมวดหมู่: $e');
    }
  }

  @override
  Future<void> addCategory(String name) async {
    try {
      await _apiService.addCategory(name);
    } catch (e) {
      ErrorHandler.logError('Error adding category: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการเพิ่มหมวดหมู่: $e');
    }
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    try {
      await _apiService.updateCategory(oldName, newName);
    } catch (e) {
      ErrorHandler.logError('Error updating category: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการอัปเดตหมวดหมู่: $e');
    }
  }

  @override
  Future<void> deleteCategory(String name) async {
    try {
      await _apiService.deleteCategory(name);
    } catch (e) {
      ErrorHandler.logError('Error deleting category: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการลบหมวดหมู่: $e');
    }
  }

  @override
  Future<List<String>> getDepartments() async {
    try {
      return await _apiService.getDepartments();
    } catch (e) {
      ErrorHandler.logError('Error getting departments: $e');

      // กรณีที่ API ยังไม่รองรับ - คืนค่าเริ่มต้นเพื่อให้แอปทำงานต่อได้
      if (e is FetchDataException || e is DatabaseException) {
        return ['Production', 'Warehouse', 'Office'];
      }

      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการดึงข้อมูลแผนก: $e');
    }
  }

  @override
  Future<void> addDepartment(String name) async {
    try {
      await _apiService.addDepartment(name);
    } catch (e) {
      ErrorHandler.logError('Error adding department: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการเพิ่มแผนก: $e');
    }
  }

  @override
  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      await _apiService.updateDepartment(oldName, newName);
    } catch (e) {
      ErrorHandler.logError('Error updating department: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการอัปเดตแผนก: $e');
    }
  }

  @override
  Future<void> deleteDepartment(String name) async {
    try {
      await _apiService.deleteDepartment(name);
    } catch (e) {
      ErrorHandler.logError('Error deleting department: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการลบแผนก: $e');
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
      ErrorHandler.logError('Error finding asset by EPC: $e');
      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการค้นหาสินทรัพย์ด้วย EPC: $e');
    }
  }

  @override
  Future<bool> checkEpcExists(String epc) async {
    try {
      return await _apiService.checkEpcExists(epc);
    } catch (e) {
      ErrorHandler.logError('Error checking EPC existence: $e');

      // กรณีที่ API ยังไม่รองรับ - ใช้วิธีค้นหาจากข้อมูลที่มีอยู่แทน
      if (e is FetchDataException) {
        final asset = await findAssetByEpc(epc);
        return asset != null;
      }

      if (e is AppException) {
        rethrow;
      }
      throw DatabaseException('เกิดข้อผิดพลาดในการตรวจสอบ EPC: $e');
    }
  }

  @override
  Future<bool> createAsset(Asset asset) async {
    try {
      final assetModel = asset as AssetModel;
      final assetData = assetModel.toMap();

      // ตรวจสอบและแก้ไขค่าที่เป็นค่าว่าให้เป็น '0'
      if (assetData['batteryLevel'] == '') {
        assetData['batteryLevel'] = '0';
      }

      if (assetData['value'] == '') {
        assetData['value'] = '0';
      }

      return await _apiService.createAsset(assetData);
    } catch (e) {
      ErrorHandler.logError('Error creating asset: $e');

      // แยกประเภทข้อผิดพลาดให้ชัดเจน
      if (e is ConflictException) {
        // แสดงข้อความเฉพาะสำหรับกรณีข้อมูลซ้ำ
        throw ConflictException(
          'มีสินทรัพย์นี้ในระบบแล้ว ไม่สามารถสร้างซ้ำได้',
        );
      } else if (e is ValidationException) {
        // ส่งต่อข้อผิดพลาดเกี่ยวกับการตรวจสอบข้อมูล
        rethrow;
      } else if (e is AppException) {
        // ส่งต่อ exceptions อื่นๆ
        rethrow;
      }

      // แปลงข้อผิดพลาดทั่วไปเป็น DatabaseException
      throw DatabaseException('เกิดข้อผิดพลาดในการสร้างสินทรัพย์: $e');
    }
  }

  @override
  Future<Asset?> updateAsset(Asset asset) async {
    // ยังไม่ได้ implement - จะเพิ่มในอนาคต
    throw UnimplementedError('Method not implemented yet');
  }

  @override
  Future<String?> exportAssetsToCSV(
    List<Asset> assets,
    List<String> columns,
  ) async {
    // ยังไม่ได้ implement - จะเพิ่มในอนาคต
    throw UnimplementedError('Method not implemented yet');
  }

  @override
  Future<bool> updateAssetStatusToChecked(
    String tagId, {
    String? lastScannedBy,
  }) async {
    try {
      ErrorHandler.logError(
        'AssetRepositoryImpl - updateAssetStatusToChecked with tagId: $tagId, scanner: $lastScannedBy',
      );
      return await _apiService.updateAssetStatusToChecked(
        tagId,
        lastScannedBy: lastScannedBy,
      );
    } catch (e) {
      ErrorHandler.logError('Error updating asset status: $e');

      // แยกประเภทข้อผิดพลาดเพื่อให้การจัดการเฉพาะทาง
      if (e is ValidationException) {
        // กรณีสถานะไม่ถูกต้อง
        throw ValidationException(
          'สถานะปัจจุบันไม่สามารถอัปเดตเป็น Checked ได้',
        );
      } else if (e is NotFoundException) {
        // กรณีไม่พบสินทรัพย์
        throw AssetNotFoundException('ไม่พบสินทรัพย์ที่มีรหัส: $tagId');
      } else if (e is AppException) {
        // ส่งต่อ custom exceptions อื่นๆ
        rethrow;
      }

      // แปลงข้อผิดพลาดทั่วไปเป็น DatabaseException
      throw DatabaseException('เกิดข้อผิดพลาดในการอัปเดตสถานะสินทรัพย์: $e');
    }
  }
}
