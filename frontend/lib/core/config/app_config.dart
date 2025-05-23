class AppConfig {
  // การตั้งค่าพื้นฐานของแอพ
  static const String appName = 'RFID Asset Management';
  static const String appVersion = '1.0.0';
  static const bool isDevelopment = true;

  // การตั้งค่าเกี่ยวกับการเชื่อมต่อกับ API
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api';

  // สวิตช์เปิด-ปิดความสามารถต่างๆ
  static const bool enableAnalytics = false;
  static const bool enableNotifications = true;

  // ใช้ API แทนการเชื่อมต่อฐานข้อมูลโดยตรง
  static const bool useRemoteDatabase = true;
}
