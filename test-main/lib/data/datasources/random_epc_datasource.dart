import 'dart:math';
import '../../../domain/repositories/asset_repository.dart';

/// Interface สำหรับการอ่านข้อมูล EPC
abstract class EpcDatasource {
  /// อ่าน EPC (Electronic Product Code)
  Future<String?> getEpc();
}

/// การจำลองโดยสุ่ม EPC จากฐานข้อมูล
class RandomEpcDatasource implements EpcDatasource {
  final AssetRepository _assetRepository;

  RandomEpcDatasource(this._assetRepository);

  @override
  Future<String?> getEpc() async {
    try {
      // จำลองความล่าช้าเหมือนการสแกนจริง
      await Future.delayed(const Duration(milliseconds: 800));

      // ดึงสินทรัพย์ทั้งหมดจาก repository
      final assets = await _assetRepository.getAssets();

      // ตรวจสอบว่ามีข้อมูลหรือไม่
      if (assets.isEmpty) {
        return null;
      }

      // สุ่มเลือกหนึ่งสินทรัพย์
      final random = Random();
      final randomAsset = assets[random.nextInt(assets.length)];

      // คืนค่า EPC ของสินทรัพย์นั้น
      return randomAsset.epc;
    } catch (e) {
      print('Error getting random EPC: $e');
      return null;
    }
  }
}

// ในอนาคตเมื่อมีอุปกรณ์จริง:
// 
// class RealRfidScannerDatasource implements EpcDatasource {
//   @override
//   Future<String?> getEpc() async {
//     // โค้ดเชื่อมต่อกับอุปกรณ์ RFID จริง
//     // return rfidReader.readEpc();
//   }
// }