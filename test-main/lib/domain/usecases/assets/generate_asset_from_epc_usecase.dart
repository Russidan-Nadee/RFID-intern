// ใน lib/domain/usecases/assets/generate_asset_from_epc_usecase.dart
import 'dart:math';
import 'package:intl/intl.dart';
import '../../../data/models/asset_model.dart';
import '../../../domain/entities/asset.dart';
import '../../../domain/repositories/asset_repository.dart';

class GenerateAssetFromEpcUseCase {
  final AssetRepository repository;
  final Random _random = Random();

  GenerateAssetFromEpcUseCase(this.repository);

  // แก้ไขเมธอด execute เดิม ให้เป็นแบบนี้
  Future<Asset> execute(String epc) async {
    try {
      // สร้าง ID แบบลำดับถัดไป
      final assets = await repository.getAssets();
      final nextId = assets.isEmpty ? 1 : assets.length + 1;

      // สร้าง tagId
      final tagId = 'TAG${nextId.toString().padLeft(4, '0')}';

      // สร้าง itemId
      final itemId = 'ITM${nextId.toString().padLeft(4, '0')}';

      // สร้าง itemName
      final itemName = 'Item $nextId';

      // หมวดหมู่
      final categories = [
        'Finished Good',
        'Equipment',
        'Raw Material',
        'Tool',
        'Work in Progress',
        'Packaging',
      ];
      final category = categories[_random.nextInt(categories.length)];

      // สถานะ
      final statuses = ['Available', 'Checked'];
      final status = statuses[_random.nextInt(statuses.length)];

      // ประเภทแท็ก
      final tagTypes = ['Passive', 'Active', 'Semi-Passive', 'BAP'];
      final tagType = tagTypes[_random.nextInt(tagTypes.length)];

      // วันที่ขาย
      final saleDate = _generateRandomDate(2023, 2024);

      // ความถี่
      final frequencies = ['UHF', 'HF', 'LF', 'NFC'];
      final frequency = frequencies[_random.nextInt(frequencies.length)];

      // ตำแหน่งปัจจุบัน
      final locations = [
        'Warehouse A',
        'Warehouse B',
        'Production Line 1',
        'Shipping Dock',
        'Receiving Dock',
        'Unknown',
      ];
      final currentLocation = locations[_random.nextInt(locations.length)];

      // โซน
      final zones = ['Storage', 'Manufacturing', 'Logistics', 'Unknown'];
      final zone = zones[_random.nextInt(zones.length)];

      // เวลาสแกนล่าสุด
      final lastScanTime = _generateRandomDate(2025, 2025);

      // ผู้สแกนล่าสุด
      final scanners = [
        'Automatic Scan',
        'Michael Lee',
        'Sarah Johnson',
        'John Smith',
        'Emma Davis',
      ];
      final lastScannedBy = scanners[_random.nextInt(scanners.length)];

      // ระดับแบตเตอรี่
      final hasBattery = _random.nextBool();
      final batteryLevel = hasBattery ? _random.nextInt(100).toString() : '';

      // เลขชุดการผลิต
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

      // วันที่ผลิต
      final hasManufDate = _random.nextBool();
      final manufacturingDate =
          hasManufDate ? _generateRandomDate(2023, 2024) : '';

      // วันหมดอายุ
      final hasExpiry = _random.nextInt(5) == 0;
      final expiryDate = hasExpiry ? _generateRandomDate(2025, 2026) : '';

      // มูลค่า
      final value = (1 + _random.nextDouble() * 99).toStringAsFixed(2);

      // สร้าง AssetModel
      final asset = AssetModel(
        id: nextId.toString(),
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
        lastScanTime: lastScanTime,
        lastScannedBy: lastScannedBy,
        batteryLevel: batteryLevel,
        batchNumber: batchNumber,
        manufacturingDate: manufacturingDate,
        expiryDate: expiryDate,
        value: value,
      );

      // ส่วนที่เพิ่มเข้ามาใหม่: บันทึกลงฐานข้อมูลจริง
      final success = await repository.createAsset(asset);

      if (!success) {
        throw Exception('ไม่สามารถสร้างสินทรัพย์ในฐานข้อมูลได้');
      }

      return asset;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการสร้างสินทรัพย์: $e');
      throw Exception('ไม่สามารถสร้างสินทรัพย์ได้: $e');
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

  // เพิ่มเมธอดนี้เข้าไปในคลาส
  // เมธอดนี้จะสร้างข้อมูลตัวอย่างโดยไม่บันทึกลงฐานข้อมูล
  Future<Asset> generatePreview(String epc) async {
    try {
      // สร้างวันที่ปัจจุบัน
      final now = DateTime.now();
      final lastScanTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // ดึงข้อมูลสินทรัพย์ทั้งหมดเพื่อหา ID ล่าสุด
      final assets = await repository.getAssets();

      // หาค่า ID สูงสุดที่มีอยู่
      int maxId = 0;
      for (var asset in assets) {
        // แปลง id จาก String เป็น int โดยเอาเฉพาะตัวเลข
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

      // ส่วนที่เหลือคงเดิม...
      final categories = [
        'Finished Good',
        'Equipment',
        'Raw Material',
        'Tool',
        'Work in Progress',
        'Packaging',
      ];
      final category = categories[_random.nextInt(categories.length)];

      // สถานะ - แก้ไขให้มีเพียง Available และ Checked
      final statuses = ['Available', 'Checked'];
      final status = statuses[_random.nextInt(statuses.length)];

      // ประเภทแท็ก
      final tagTypes = ['Passive', 'Active', 'Semi-Passive', 'BAP'];
      final tagType = tagTypes[_random.nextInt(tagTypes.length)];

      // วันที่ขาย
      final saleDate = _generateRandomDate(2023, 2024);

      // ความถี่
      final frequencies = ['UHF', 'HF', 'LF', 'NFC'];
      final frequency = frequencies[_random.nextInt(frequencies.length)];

      // ตำแหน่งปัจจุบัน
      final locations = [
        'Warehouse A',
        'Warehouse B',
        'Production Line 1',
        'Shipping Dock',
        'Receiving Dock',
        'Unknown',
      ];
      final currentLocation = locations[_random.nextInt(locations.length)];

      // โซน
      final zones = ['Storage', 'Manufacturing', 'Logistics', 'Unknown'];
      final zone = zones[_random.nextInt(zones.length)];

      // เวลาสแกนล่าสุด
      final scanTime = _generateRandomDate(2025, 2025);

      // ผู้สแกนล่าสุด
      final scanners = [
        'Automatic Scan',
        'Michael Lee',
        'Sarah Johnson',
        'John Smith',
        'Emma Davis',
      ];
      final lastScannedBy = scanners[_random.nextInt(scanners.length)];

      // ระดับแบตเตอรี่
      final hasBattery = _random.nextBool();
      final batteryLevel = hasBattery ? _random.nextInt(100).toString() : '0';

      // เลขชุดการผลิต
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

      // วันที่ผลิต - มีหรือไม่มีก็ได้
      final hasManufDate = _random.nextBool();
      final manufacturingDate =
          hasManufDate ? _generateRandomDate(2023, 2024) : '';

      // วันหมดอายุ - อาจจะมีหรือไม่มีก็ได้
      final hasExpiry = _random.nextInt(5) == 0; // 20% โอกาสที่จะมีวันหมดอายุ
      final expiryDate = hasExpiry ? _generateRandomDate(2025, 2026) : '';

      // มูลค่า
      final value = (1 + _random.nextDouble() * 99).toStringAsFixed(2);

      // สร้าง AssetModel แต่ไม่บันทึกลงฐานข้อมูล
      return AssetModel(
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
    } catch (e) {
      print('Error generating preview: $e');
      // สร้างข้อมูลขั้นต่ำในกรณีมีข้อผิดพลาด
      return AssetModel(
        id: '0',
        tagId: 'TAG0000',
        epc: epc,
        itemId: 'ITM0000',
        itemName: 'Unknown Item',
        category: 'Unknown',
        status: 'Available', // เปลี่ยนจาก 'Unknown' เป็น 'Available'
        tagType: 'Unknown',
        saleDate: '',
        frequency: '',
        currentLocation: '',
        zone: '',
        lastScanTime: '',
        lastScannedBy: '',
        batteryLevel: '',
        batchNumber: '',
        manufacturingDate: '',
        expiryDate: '',
        value: '0',
      );
    }
  }
}
