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

  // สวิตช์เปิด-ปิดความสามารถต่างๆ
  static const bool enableAnalytics = false; // ปิดการเก็บสถิติการใช้งาน
  static const bool enableNotifications = true; // เปิดการแจ้งเตือน
}
