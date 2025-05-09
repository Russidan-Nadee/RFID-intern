// คลาสนี้เก็บรายชื่อทางเข้าหน้าต่างๆ ในแอป
class RouteConstants {
  // หน้าจอหลักที่ใช้งานบ่อย
  // หน้าแรกที่เห็นเมื่อเปิดแอป
  static const String home = '/';
  // หน้าสำหรับค้นหาของ
  static const String searchAssets = '/searchAssets';
  // หน้าสำหรับสแกนป้ายติดของ
  static const String scanRfid = '/scanRfid';
  // หน้าแสดงรายการของทั้งหมด
  static const String viewAssets = '/viewAssets';
  // หน้าส่งออกข้อมูล
  static const String export = '/export';

  // หน้าแสดงผลลัพธ์การค้นหา
  // หน้าแสดงเมื่อพบของที่หา
  static const String found = '/found';
  // หน้าแสดงเมื่อหาไม่พบ
  static const String notFound = '/notFound';

  // หน้าจอเพิ่มเติมอื่นๆ
  // หน้าปรับแต่งแอป
  static const String settings = '/settings';
  // หน้าข้อมูลส่วนตัว
  static const String profile = '/profile';
  // หน้าแสดงรายงานต่างๆ
  static const String reports = '/reports';
}
