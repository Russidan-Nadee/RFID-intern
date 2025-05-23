// lib/presentation/features/rfid/blocs/rfid_scan_bloc.dart
import 'package:flutter/material.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';

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

      if (_scanResults.isEmpty) {
        throw RfidScanException("ไม่พบผลลัพธ์การสแกน");
      } else if (_scanResults.first.success == false) {
        throw RfidScanException(_scanResults.first.errorMessage);
      } else {
        _status = RfidScanStatus.scanned;
      }
    } on RfidScanException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - RfidScan error: ${e.toString()}');
    } on NetworkException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Network error in RFID scan: ${e.toString()}');
    } on DatabaseException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Database error in RFID scan: ${e.toString()}');
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage =
          "เกิดข้อผิดพลาดที่ไม่คาดคิดในการสแกน กรุณาลองใหม่อีกครั้ง";
      print('DEBUG - Unexpected error in RFID scan: $e');
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
