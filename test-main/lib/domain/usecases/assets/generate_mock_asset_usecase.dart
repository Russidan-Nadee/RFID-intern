import 'dart:math';
import 'package:intl/intl.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler.dart';
import '../../../core/validation/asset_validator.dart';
import '../../../data/models/asset_model.dart';
import '../../../domain/entities/asset.dart';
import '../../../domain/repositories/asset_repository.dart';

/// UseCase สำหรับสร้างข้อมูลจำลองของสินทรัพย์
class GenerateMockAssetUseCase {
  final AssetRepository repository;
  final AssetValidator validator;
  final Random _random = Random();

  GenerateMockAssetUseCase(this.repository)
    : validator = AssetValidator(repository);

  /// สร้างข้อมูลสินทรัพย์จำลองจาก EPC
  Future<Asset> execute(String epc) async {
    try {
      // ตรวจสอบความถูกต้องของ EPC
      await validator.validateEpc(epc);

      // สร้างวันที่ปัจจุบัน
      final now = DateTime.now();
      final lastScanTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // ดึงข้อมูลสินทรัพย์เพื่อสร้าง ID ลำดับถัดไป
      final assets = await repository.getAssets();

      // หาค่า ID สูงสุดที่มีอยู่
      int maxId = 0;
      for (var asset in assets) {
        int? assetId = int.tryParse(asset.id.replaceAll(RegExp(r'[^0-9]'), ''));
        if (assetId != null && assetId > maxId) {
          maxId = assetId;
        }
      }

      // กำหนด ID ใหม่เป็นค่าถัดไป
      final nextId = (maxId + 1).toString();

      // สร้าง tagId
      final tagId = 'TAG${nextId.padLeft(4, '0')}';

      // สร้าง itemId
      final itemId = 'ITM${nextId.padLeft(4, '0')}';

      // สร้าง itemName
      final itemName = 'Item $nextId';

      // เลือกข้อมูลที่ถูกต้องตามที่กำหนด
      final category =
          AssetValidator.validCategories[_random.nextInt(
            AssetValidator.validCategories.length,
          )];
      final status =
          AssetValidator.validStatuses[_random.nextInt(
            AssetValidator.validStatuses.length,
          )];
      final tagType =
          AssetValidator.validTagTypes[_random.nextInt(
            AssetValidator.validTagTypes.length,
          )];

      // สร้างข้อมูลอื่นๆ
      final saleDate = _generateRandomDate(2023, 2024);
      final frequency = ['UHF', 'HF', 'LF', 'NFC'][_random.nextInt(4)];

      final locations = [
        'Warehouse A',
        'Warehouse B',
        'Production Line 1',
        'Shipping Dock',
        'Receiving Dock',
        'Unknown',
      ];
      final currentLocation = locations[_random.nextInt(locations.length)];

      final zones = ['Storage', 'Manufacturing', 'Logistics', 'Unknown'];
      final zone = zones[_random.nextInt(zones.length)];

      final scanTime = _generateRandomDate(2025, 2025);

      final scanners = [
        'Automatic Scan',
        'Michael Lee',
        'Sarah Johnson',
        'John Smith',
        'Emma Davis',
      ];
      final lastScannedBy = scanners[_random.nextInt(scanners.length)];

      // สร้างค่าอื่นๆ
      final hasBattery = _random.nextBool();
      final batteryLevel = hasBattery ? _random.nextInt(100).toString() : '0';

      final batchPrefix = [
        'KK',
        'PG',
        'HY',
        'CK',
        'IV',
        'ED',
        'NC',
        'HG',
        'NT',
        'JS',
        'RL',
        'XY',
      ];
      final batchSuffix = _random.nextInt(10000).toString().padLeft(4, '0');
      final batchNumber =
          '${batchPrefix[_random.nextInt(batchPrefix.length)]}-$batchSuffix';

      final hasManufDate = _random.nextBool();
      final manufacturingDate =
          hasManufDate ? _generateRandomDate(2023, 2024) : '';

      final hasExpiry = _random.nextInt(5) == 0;
      final expiryDate = hasExpiry ? _generateRandomDate(2025, 2026) : '';

      final value = (1 + _random.nextDouble() * 99).toStringAsFixed(2);

      // สร้าง AssetModel
      final asset = AssetModel(
        id: nextId,
        tagId: tagId,
        epc: epc,
        itemId: itemId,
        itemName: itemName,
        category: category,
        status: status,
        tagType: tagType,
        saleDate: saleDate,
        frequency: frequency,
        currentLocation: currentLocation,
        zone: zone,
        lastScanTime: scanTime,
        lastScannedBy: lastScannedBy,
        batteryLevel: batteryLevel,
        batchNumber: batchNumber,
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        value: value,
      );

      // ตรวจสอบข้อมูลสินทรัพย์
      validator.validateAssetData(asset.toMap());

      return asset;
    } catch (e) {
      ErrorHandler.logError('Error generating mock asset: $e');

      // ส่งต่อ custom exceptions
      if (e is AppException) rethrow;

      // แปลงข้อผิดพลาดทั่วไปเป็น Exception ที่เหมาะสม
      throw ValidationException('ไม่สามารถสร้างสินทรัพย์จำลองได้: $e');
    }
  }

  // ฟังก์ชันสร้างวันที่แบบสุ่ม

  String _generateRandomDate(int yearStart, int yearEnd) {
    final year = yearStart + _random.nextInt(yearEnd - yearStart + 1);
    final month = 1 + _random.nextInt(12);
    final day = 1 + _random.nextInt(28);
    final hour = _random.nextInt(24);
    final minute = _random.nextInt(60);
    final second = _random.nextInt(60);

    return DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime(year, month, day, hour, minute, second));
  }

  Future<Asset> generatePreview(String epc) async {
    return await execute(epc);
  }
}
