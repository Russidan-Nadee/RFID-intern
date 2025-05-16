import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';

/// สถานะการสแกน RFID
enum RfidScanStatus {
  initial, // สถานะเริ่มต้น
  scanning, // กำลังสแกน
  scanned, // สแกนเสร็จแล้ว (พบหรือไม่พบก็ได้)
  error, // เกิดข้อผิดพลาด
}

/// Bloc สำหรับจัดการการสแกน RFID
class RfidScanBloc extends ChangeNotifier {
  /// UseCase สำหรับการสแกน RFID
  final ScanRfidUseCase _scanRfidUseCase;

  /// สถานะปัจจุบันของการสแกน
  RfidScanStatus _status = RfidScanStatus.initial;

  /// EPC ที่สแกนได้
  String? _scannedEpc;

  /// สินทรัพย์ที่พบจากการสแกน
  Asset? _scannedAsset;

  /// ข้อความแสดงข้อผิดพลาด (ถ้ามี)
  String _errorMessage = '';

  /// สร้าง RfidScanBloc
  RfidScanBloc(this._scanRfidUseCase);

  /// สถานะปัจจุบันของการสแกน
  RfidScanStatus get status => _status;

  /// EPC ที่สแกนได้
  String? get scannedEpc => _scannedEpc;

  /// สินทรัพย์ที่พบจากการสแกน
  Asset? get scannedAsset => _scannedAsset;

  /// ข้อความแสดงข้อผิดพลาด
  String get errorMessage => _errorMessage;

  /// ตรวจสอบว่าพบสินทรัพย์หรือไม่
  bool get isAssetFound => _scannedAsset != null;

  /// ดำเนินการสแกน RFID
  Future<void> performScan(BuildContext context) async {
    // เปลี่ยนสถานะเป็นกำลังสแกน
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      // เรียกใช้ UseCase เพื่อสแกน
      final result = await _scanRfidUseCase.execute(context);

      // บันทึกผลลัพธ์
      _scannedEpc = result.epc;
      _scannedAsset = result.asset;

      // ตรวจสอบสถานะการสแกน
      if (result.success) {
        _status = RfidScanStatus.scanned;
      } else {
        _status = RfidScanStatus.error;
        _errorMessage = result.errorMessage ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      _status = RfidScanStatus.error;
      _errorMessage = e.toString();
    }

    // แจ้งเตือน UI ให้อัพเดต
    notifyListeners();
  }

  /// รีเซ็ตสถานะการสแกน
  void resetScan() {
    _status = RfidScanStatus.initial;
    _scannedEpc = null;
    _scannedAsset = null;
    _errorMessage = '';
    notifyListeners();
  }

  void navigateToAssetDetail(BuildContext context, Asset asset) {
    Navigator.pushNamed(
      context,
      '/assetDetail',
      arguments: {'guid': asset.tagId},
    );
  }
}
