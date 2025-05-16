/* Path: lib/data/datasources/epc_datasource.dart */
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

      // สุ่มจำนวน EPC จริงที่ต้องการ (4-6 รายการ)
      final random = Random();
      final dbItemCount = min(
        4 + random.nextInt(3), // สุ่มจำนวน 4-6
        assets.length,
      );

      // ถ้าไม่มีข้อมูลในฐานข้อมูลหรือมีไม่พอ
      if (assets.isEmpty || assets.length < 4) {
        // สร้าง EPC สุ่มแทนข้อมูลจริงที่ไม่พอ
        int randomItemsNeeded = assets.isEmpty ? 5 : (4 - assets.length);

        // เพิ่ม EPC จากฐานข้อมูลทั้งหมดที่มี
        for (final asset in assets) {
          if (asset.epc.isNotEmpty) {
            epcSet.add(asset.epc);
          }
        }

        // เพิ่ม EPC สุ่มให้ครบจำนวนที่ต้องการ
        while (epcSet.length < randomItemsNeeded + assets.length) {
          epcSet.add(generateRandomEpc());
        }
      } else {
        // มีข้อมูลในฐานข้อมูลเพียงพอ

        // สุ่มเลือก EPC จากฐานข้อมูล dbItemCount รายการ
        List<int> randomIndices = [];
        while (randomIndices.length < dbItemCount) {
          final randomIndex = random.nextInt(assets.length);
          if (!randomIndices.contains(randomIndex)) {
            randomIndices.add(randomIndex);
          }
        }

        // เพิ่ม EPC จากฐานข้อมูลตามที่สุ่มได้
        for (final index in randomIndices) {
          final asset = assets[index];
          if (asset.epc.isNotEmpty) {
            epcSet.add(asset.epc);
          }
        }
      }

      // เพิ่ม EPC สุ่มอีก 1 รายการเสมอ
      epcSet.add(generateRandomEpc());

      // แปลงเป็น List และคืนค่า
      return epcSet.toList();
    } catch (e) {
      print('Error getting random EPCs: $e');
      return [];
    }
  }
}
