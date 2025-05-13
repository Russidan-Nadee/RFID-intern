// lib/core/constants/route_constants.dart
class RouteConstants {
  // หน้าจอหลักที่ใช้งานบ่อย
  // หน้าแรกที่เห็นเมื่อเปิดแอป
  static const String home = '/';
  // หน้าสำหรับค้นหาของ
  static const String searchAssets = '/searchAssets';
  // หน้าสำหรับสแกนป้ายติดของ
  static const String scanRfid = '/scanRfid';
  // หน้าแสดงรายงานต่างๆ (เปลี่ยนจาก viewAssets)
  static const String reports = '/reports';
  // หน้าส่งออกข้อมูล
  static const String export = '/export';

  // หน้าแสดงผลลัพธ์การค้นหา
  // หน้าแสดงเมื่อพบของที่หา
  static const String found = '/found';
  // หน้าแสดงเมื่อหาไม่พบ
  static const String notFound = '/notFound';
  // หน้าแสดงรายละเอียดสินทรัพย์เต็ม
  static const String assetDetail = '/assetDetail';

  // หน้าจอเพิ่มเติมอื่นๆ
  // หน้าปรับแต่งแอป
  static const String settings = '/settings';
  // หน้าข้อมูลส่วนตัว
  static const String profile = '/profile';

  static const String databaseTest = '/databaseTest';
}
