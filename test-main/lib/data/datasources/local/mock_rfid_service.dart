import 'dart:async';
import 'dart:math';
import '../../../core/services/rfid_service.dart';

// โหมดการจำลองสำหรับทดสอบ
enum MockMode {
  normal, // โหมดปกติ (สุ่ม)
  found, // จำลองว่าเจอสินทรัพย์ในระบบ
  notFound, // จำลองว่าไม่เจอสินทรัพย์ในระบบ
  scanFailed, // จำลองว่าสแกนไม่สำเร็จ
}

class MockRfidService implements RfidService {
  // UID ที่มีในระบบ (จำลอง)
  final List<String> _registeredUids = [
    'ABC1234567',
    'XYZ9876543',
    'DEF5678901',
  ];

  // UID ที่ไม่มีในระบบ (จำลอง)
  final List<String> _unregisteredUids = [
    'UNR1234567',
    'NEW9876543',
    'MIS5678901',
  ];

  bool _scanning = false;
  MockMode _currentMode = MockMode.normal;

  // เมธอดเพิ่มเติมสำหรับการตั้งค่าโหมดการจำลอง
  void setMockMode(MockMode mode) {
    _currentMode = mode;
  }

  // ดึงค่าโหมดปัจจุบัน
  MockMode get currentMode => _currentMode;

  @override
  bool isAvailable() {
    // จำลองว่าอุปกรณ์พร้อมใช้งานเสมอ
    return true;
  }

  @override
  Future<String?> scanRfid() async {
    _scanning = true;

    // จำลองเวลาที่ใช้ในการสแกน (1-2 วินาที)
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(1000)));

    _scanning = false;

    // ตรวจสอบโหมดการจำลองและส่งค่ากลับตามโหมด
    switch (_currentMode) {
      case MockMode.found:
        // ส่งค่า UID ที่มีในระบบกลับไป
        return _registeredUids[Random().nextInt(_registeredUids.length)];

      case MockMode.notFound:
        // ส่งค่า UID ที่ไม่มีในระบบกลับไป
        return _unregisteredUids[Random().nextInt(_unregisteredUids.length)];

      case MockMode.scanFailed:
        // จำลองการสแกนล้มเหลว
        return null;

      case MockMode.normal:
        // โหมดปกติ - สุ่มว่าจะสแกนสำเร็จหรือไม่ และสุ่มว่าจะเจอหรือไม่เจอ
        if (Random().nextDouble() < 0.9) {
          // 90% โอกาสที่จะสแกนสำเร็จ
          if (Random().nextBool()) {
            // 50% โอกาสที่จะเจอในระบบ
            return _registeredUids[Random().nextInt(_registeredUids.length)];
          } else {
            // 50% โอกาสที่จะไม่เจอในระบบ
            return _unregisteredUids[Random().nextInt(
              _unregisteredUids.length,
            )];
          }
        } else {
          // 10% โอกาสที่จะสแกนไม่สำเร็จ
          return null;
        }
    }
  }

  @override
  bool isScanning() {
    return _scanning;
  }

  @override
  void stopScan() {
    _scanning = false;
  }
}
