import '../../../data/datasources/random_epc_datasource.dart';
import '../../entities/epc_scan_result.dart';
import '../assets/find_asset_by_epc_usecase.dart';

// ใน lib/domain/usecases/rfid/scan_rfid_usecase.dart
class ScanRfidUseCase {
  final EpcDatasource _epcDatasource;
  final FindAssetByEpcUseCase _findAssetByEpcUseCase;

  ScanRfidUseCase(this._epcDatasource, this._findAssetByEpcUseCase);

  Future<List<EpcScanResult>> execute() async {
    try {
      // อ่าน EPCs จากแหล่งข้อมูล
      final epcs = await _epcDatasource.getEpcs();

      // ถ้าไม่ได้ EPCs
      if (epcs.isEmpty) {
        return [EpcScanResult.error('ไม่สามารถอ่าน EPC ได้')];
      }

      // ค้นหาสินทรัพย์จากแต่ละ EPC
      List<EpcScanResult> results = [];
      for (String epc in epcs) {
        // ที่นี่คือจุดที่ต้องแก้ - ต้องเพิ่มผลลัพธ์เข้ารายการ
        final result = await _findAssetByEpcUseCase.execute(epc);
        results.add(result); // ใช้ add เพื่อเพิ่มเข้ารายการ
      }

      return results;
    } catch (e) {
      return [EpcScanResult.error('เกิดข้อผิดพลาดในการสแกน: ${e.toString()}')];
    }
  }
}
