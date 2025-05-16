import 'dart:math';
import '../../../domain/repositories/asset_repository.dart';

/// Interface สำหรับการอ่านข้อมูล EPC
abstract class EpcDatasource {
  /// อ่าน EPC หลายรายการ
  Future<List<String>> getEpcs();
}

class RandomEpcDatasource implements EpcDatasource {
  final AssetRepository _assetRepository;

  RandomEpcDatasource(this._assetRepository);

  /// สร้าง EPC แบบสุ่มในรูปแบบ SGTIN
  String generateRandomEpc() {
    final random = Random();

    // สร้างเลขบริษัท (Company Prefix) 6 หลัก
    final companyPrefix = random.nextInt(999999).toString().padLeft(6, '0');

    // สร้างรหัสสินค้า (Item Reference) 3 หลัก
    final itemReference = random.nextInt(999).toString().padLeft(3, '0');

    // สร้างเลขซีเรียล (Serial Number) 7 หลัก
    final serialNumber = random.nextInt(9999999).toString().padLeft(7, '0');

    // สร้าง EPC ในรูปแบบ SGTIN
    return 'urn:epc:id:sgtin:$companyPrefix.$itemReference.$serialNumber';
  }

  @override
  Future<List<String>> getEpcs() async {
    try {
      // จำลองความล่าช้าเหมือนการสแกนจริง
      await Future.delayed(const Duration(milliseconds: 800));

      // ดึงสินทรัพย์ทั้งหมดจาก repository
      final assets = await _assetRepository.getAssets();

      // ใช้ Set เพื่อป้องกันข้อมูลซ้ำ
      Set<String> epcSet = {};

      // สุ่มจำนวน EPC ที่ต้องการ (2-4 รายการ)
      final random = Random();
      final totalItemCount = random.nextInt(3) + 2; // สุ่มจำนวน 2-4

      // จำนวน EPC จากฐานข้อมูล (1-2 รายการ)
      final dbItemCount = min(
        assets.isEmpty ? 0 : random.nextInt(2) + 1,
        assets.length,
      );

      // เพิ่ม EPC จากฐานข้อมูล
      for (int i = 0; i < dbItemCount; i++) {
        final randomIndex = random.nextInt(assets.length);
        final randomAsset = assets[randomIndex];
        if (randomAsset.epc.isNotEmpty) {
          epcSet.add(randomAsset.epc);
        }
      }

      // เพิ่ม EPC สุ่มเพิ่มเติมให้ครบจำนวน
      while (epcSet.length < totalItemCount) {
        epcSet.add(generateRandomEpc());
      }

      // แปลงเป็น List และคืนค่า
      return epcSet.toList();
    } catch (e) {
      print('Error getting random EPCs: $e');
      return [];
    }
  }
}
