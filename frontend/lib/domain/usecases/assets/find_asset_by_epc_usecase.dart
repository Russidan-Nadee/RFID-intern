import '../../entities/epc_scan_result.dart';
import '../../repositories/asset_repository.dart';

/// UseCase สำหรับค้นหาสินทรัพย์จาก EPC
class FindAssetByEpcUseCase {
  /// Repository สำหรับจัดการข้อมูลสินทรัพย์
  final AssetRepository _repository;

  /// สร้าง FindAssetByEpcUseCase
  FindAssetByEpcUseCase(this._repository);

  /// ค้นหาสินทรัพย์จาก EPC
  ///
  /// [epc] คือ EPC ที่ต้องการค้นหา
  /// คืนค่า EpcScanResult ที่มีข้อมูลสินทรัพย์หรือข้อผิดพลาด
  Future<EpcScanResult> execute(String epc) async {
    try {
      // ถ้าไม่มี EPC หรือ EPC เป็นค่าว่าง
      if (epc.isEmpty) {
        return EpcScanResult.error('EPC ไม่ถูกต้อง');
      }

      // เปลี่ยนจาก findAssetByTagId เป็น findAssetByEpc
      final asset = await _repository.findAssetByEpc(epc);

      // ถ้าพบสินทรัพย์
      if (asset != null) {
        return EpcScanResult.success(epc, asset);
      }
      // ถ้าไม่พบสินทรัพย์
      else {
        return EpcScanResult.notFound(epc);
      }
    } catch (e) {
      // กรณีเกิดข้อผิดพลาด
      return EpcScanResult.error('เกิดข้อผิดพลาดในการค้นหา: ${e.toString()}');
    }
  }
}
