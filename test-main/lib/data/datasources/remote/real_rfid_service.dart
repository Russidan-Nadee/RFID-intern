import 'dart:async';
import '../../../core/services/rfid_service.dart';

class RealRfidService implements RfidService {
  bool _isScanning = false;

  // เก็บข้อมูล GUID ที่จะใช้ในการสแกน
  String? _manualGuid;

  // เมธอดเพิ่มเติมสำหรับรับค่า GUID ที่ผู้ใช้ป้อนเอง
  void setManualGuid(String guid) {
    _manualGuid = guid;
  }

  @override
  bool isAvailable() {
    // พร้อมใช้งานเสมอเพราะเป็นการป้อนข้อมูลเอง
    return true;
  }

  @override
  Future<String?> scanRfid() async {
    try {
      _isScanning = true;

      // จำลองการทำงาน (delay เล็กน้อย)
      await Future.delayed(Duration(milliseconds: 500));

      _isScanning = false;

      // ส่งค่า GUID ที่ผู้ใช้ป้อนเอง
      return _manualGuid;
    } catch (e) {
      _isScanning = false;
      print('Error scanning RFID: $e');
      return null;
    }
  }

  @override
  bool isScanning() {
    return _isScanning;
  }

  @override
  void stopScan() {
    _isScanning = false;
  }
}
