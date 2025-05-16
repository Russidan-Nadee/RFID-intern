import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/data/models/asset_model.dart';

class CreateAssetUseCase {
  final AssetRepository repository;

  CreateAssetUseCase(this.repository);

  /// สร้างสินทรัพย์ใหม่ในระบบ
  ///
  /// [id] คือรหัสสินทรัพย์
  /// [tagId] คือรหัส RFID tag
  /// [category] คือหมวดหมู่
  /// [itemName] คือชื่อสินค้าหรือรุ่น
  /// [currentLocation] คือตำแหน่งปัจจุบัน
  /// [status] คือสถานะ (ค่าเริ่มต้นคือ 'Available')
  Future<Asset?> execute({
    required String id,
    required String tagId,
    required String category,
    required String itemName,
    required String currentLocation,
    String status = 'Available',
  }) async {
    try {
      // สร้างวันที่ปัจจุบัน
      final now = DateTime.now();
      final lastScanTime =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // สร้าง AssetModel จากข้อมูลที่ได้รับ
      final asset = AssetModel(
        id: id.toUpperCase(),
        tagId: tagId.toUpperCase(),
        epc: tagId.toUpperCase(), // ใช้ค่าเดียวกับ tagId
        itemId: id.toUpperCase(), // ใช้ค่าเดียวกับ id
        itemName: itemName,
        category: category,
        status: status,
        tagType: 'RFID',
        saleDate: '',
        frequency: '13.56 MHz',
        currentLocation: currentLocation,
        zone: '',
        lastScanTime: lastScanTime,
        lastScannedBy: 'System',
        batteryLevel: 'N/A',
        batchNumber: '',
        manufacturingDate: '',
        expiryDate: '',
        value: '',
      );

      // บันทึกลงในฐานข้อมูล
      await repository.insertAsset(asset);

      // ส่งข้อมูลสินทรัพย์กลับไป
      return asset;
    } catch (e) {
      // กรณีเกิดข้อผิดพลาด ส่งค่า null กลับไป
      return null;
    }
  }
}
