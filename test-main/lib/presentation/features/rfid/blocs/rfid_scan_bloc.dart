import 'package:flutter/material.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';

/// สถานะการสแกน RFID
enum RfidScanStatus {
  initial, // สถานะเริ่มต้น
  scanning, // กำลังสแกน
  scanned, // สแกนเสร็จแล้ว (พบหรือไม่พบก็ได้)
  error, // เกิดข้อผิดพลาด
}

// ใน lib/presentation/features/rfid/blocs/rfid_scan_bloc.dart
class RfidScanBloc extends ChangeNotifier {
  final ScanRfidUseCase _scanRfidUseCase;

  RfidScanStatus _status = RfidScanStatus.initial;
  List<EpcScanResult> _scanResults = [];
  String _errorMessage = '';

  RfidScanBloc(this._scanRfidUseCase);

  RfidScanStatus get status => _status;
  List<EpcScanResult> get scanResults => _scanResults;
  String get errorMessage => _errorMessage;

  // ดำเนินการสแกน RFID
  Future<void> performScan(BuildContext context) async {
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      // เรียกใช้ UseCase เพื่อสแกน
      final results = await _scanRfidUseCase.execute(context);

      // บันทึกผลลัพธ์
      _scanResults = results;

      if (_scanResults.isEmpty || _scanResults.first.success == false) {
        _status = RfidScanStatus.error;
        _errorMessage =
            _scanResults.isEmpty
                ? 'ไม่พบผลลัพธ์การสแกน'
                : _scanResults.first.errorMessage ??
                    'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
      } else {
        _status = RfidScanStatus.scanned;
      }
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // รีเซ็ตสถานะการสแกน
  void resetScan() {
    _status = RfidScanStatus.initial;
    _scanResults = [];
    _errorMessage = '';
    notifyListeners();
  }
}
