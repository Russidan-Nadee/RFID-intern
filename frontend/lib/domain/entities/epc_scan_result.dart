import '../entities/asset.dart';

/// คลาสสำหรับเก็บผลลัพธ์การสแกน EPC
class EpcScanResult {
  /// EPC ที่สแกนได้
  final String? epc;

  /// สินทรัพย์ที่พบจาก EPC (null หากไม่พบ)
  final Asset? asset;

  /// สถานะการสแกน (true = สำเร็จ, false = ล้มเหลว)
  final bool success;

  /// ข้อความแสดงข้อผิดพลาด (ถ้ามี)
  final String? errorMessage;

  /// สร้าง EpcScanResult
  EpcScanResult({
    this.epc,
    this.asset,
    required this.success,
    this.errorMessage,
  });

  /// สร้าง EpcScanResult สำหรับกรณีสแกนสำเร็จและพบสินทรัพย์
  factory EpcScanResult.success(String epc, Asset asset) {
    return EpcScanResult(epc: epc, asset: asset, success: true);
  }

  /// สร้าง EpcScanResult สำหรับกรณีสแกนสำเร็จแต่ไม่พบสินทรัพย์
  factory EpcScanResult.notFound(String epc) {
    return EpcScanResult(
      epc: epc,
      success: false,
      errorMessage: 'ไม่พบสินทรัพย์ที่มี EPC: $epc',
    );
  }

  /// สร้าง EpcScanResult สำหรับกรณีเกิดข้อผิดพลาดในการสแกน
  factory EpcScanResult.error(String errorMessage) {
    return EpcScanResult(success: false, errorMessage: errorMessage);
  }
}
