import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/data/models/asset_model.dart';

class CreateAssetUseCase {
  final AssetRepository repository;

  CreateAssetUseCase(this.repository);

  /// สร้างสินทรัพย์ใหม่ในระบบ
  ///
  /// [id] คือรหัสสินทรัพย์
  /// [uid] คือรหัส RFID
  /// [category] คือหมวดหมู่
  /// [brand] คือแบรนด์หรือรุ่น
  /// [department] คือแผนกที่ดูแล
  /// [status] คือสถานะ (ค่าเริ่มต้นคือ 'Available')
  Future<Asset?> execute({
    required String id,
    required String uid,
    required String category,
    required String brand,
    required String department,
    String status = 'Available',
  }) async {
    try {
      // สร้างวันที่ปัจจุบัน
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // สร้าง AssetModel จากข้อมูลที่ได้รับ
      final asset = AssetModel(
        id: id.toUpperCase(), // แปลงเป็นตัวพิมพ์ใหญ่
        uid: uid.toUpperCase(), // แปลงเป็นตัวพิมพ์ใหญ่
        category: category,
        brand: brand,
        department: department,
        status: status,
        date: date,
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
