// ไฟล์นี้เก็บการตั้งค่าของแอพทั้งหมด

class AppConfig {
  // การตั้งค่าพื้นฐานของแอพ
  static const String appName = 'RFID Asset Management'; // ชื่อแอพ
  static const String appVersion = '1.0.0'; // เลขเวอร์ชันของแอพ
  static const bool isDevelopment =
      true; // บอกว่ากำลังพัฒนาอยู่ ยังไม่ใช่เวอร์ชันจริง

  // การตั้งค่าเกี่ยวกับการเชื่อมต่อกับเซิร์ฟเวอร์
  static const String apiBaseUrl =
      'https://api.example.com'; // ที่อยู่หลักของ API ที่จะติดต่อด้วย

  // เพิ่มการตั้งค่า MySQL ตรงนี้
  static const String mysqlHost = '10.0.2.2';
  static const int mysqlPort = 3306;
  static const String mysqlUser = 'root';
  static const String mysqlPassword =
      'first27122546'; // ใส่รหัสผ่านถ้ามีstatic const String mysqlHo
  static const String mysqlDatabase = 'rfid_assets_details';

  // สวิตช์เปิด-ปิดความสามารถต่างๆ
  static const bool enableAnalytics = false; // ปิดการเก็บสถิติการใช้งาน
  static const bool enableNotifications = true; // เปิดการแจ้งเตือน

  // เพิ่มสวิตช์เพื่อเลือกใช้ MySQL แทนการใช้ SQLite
  static const bool useRemoteDatabase =
      true; // ตั้งค่าเป็น true เมื่อต้องการใช้ MySQL
}
