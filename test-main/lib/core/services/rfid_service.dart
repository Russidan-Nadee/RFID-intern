// คลาสนี้เป็น interface สำหรับบริการ RFID ทั้งแบบจริงและแบบจำลอง
abstract class RfidService {
  // วิธีตรวจสอบว่าอุปกรณ์ RFID พร้อมใช้งานหรือไม่
  bool isAvailable();

  // วิธีสแกน RFID และส่งคืนค่า UID หรือ null ถ้าสแกนไม่สำเร็จ
  Future<String?> scanRfid();

  // ระบุว่ากำลังสแกนอยู่หรือไม่
  bool isScanning();

  // หยุดการสแกน
  void stopScan();
}
