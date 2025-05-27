import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler.dart';
import '../../validation/asset_validator.dart';
import '../../../domain/entities/asset.dart';
import '../../../domain/repositories/asset_repository.dart';

/// UseCase สำหรับสร้างและบันทึกสินทรัพย์จาก EPC
class CreateAssetUseCase {
  final AssetRepository repository;
  final AssetValidator validator;

  CreateAssetUseCase(this.repository) : validator = AssetValidator(repository);

  /// สร้างและบันทึกสินทรัพย์
  Future<Asset> execute(Asset asset) async {
    try {
      // ตรวจสอบความถูกต้องของ EPC
      await validator.validateEpc(asset.epc);

      // ตรวจสอบข้อมูลสินทรัพย์
      final assetData = _assetToMap(asset);
      validator.validateAssetData(assetData);

      // บันทึกลงฐานข้อมูล
      final success = await repository.createAsset(asset);

      if (!success) {
        throw DatabaseException('ไม่สามารถสร้างสินทรัพย์ในฐานข้อมูลได้');
      }

      return asset;
    } catch (e) {
      ErrorHandler.logError('เกิดข้อผิดพลาดในการสร้างสินทรัพย์: $e');

      // ส่งต่อ custom exceptions
      if (e is AppException) rethrow;

      // แปลงข้อผิดพลาดทั่วไปเป็น Exception ที่เหมาะสม
      throw ValidationException('ไม่สามารถสร้างสินทรัพย์ได้: $e');
    }
  }

  // แปลง Asset เป็น Map เพื่อใช้ในการตรวจสอบ
  Map<String, dynamic> _assetToMap(Asset asset) {
    return {
      'id': asset.id,
      'tagId': asset.tagId,
      'epc': asset.epc,
      'itemId': asset.itemId,
      'itemName': asset.itemName,
      'category': asset.category,
      'status': asset.status,
      'tagType': asset.tagType,
      'frequency': asset.frequency,
      'currentLocation': asset.currentLocation,
      'zone': asset.zone,
      'lastScanTime': asset.lastScanTime,
      'lastScannedBy': asset.lastScannedBy,
      'batteryLevel': asset.batteryLevel,
      'batchNumber': asset.batchNumber,
      'manufacturingDate': asset.manufacturingDate,
      'expiryDate': asset.expiryDate,
      'value': asset.value,
    };
  }
}
