// ไฟล์นี้จัดการการแจ้งเตือนแบบท้องถิ่นในแอป (การแจ้งเตือนที่แสดงบนอุปกรณ์โดยไม่ต้องใช้เซิร์ฟเวอร์)

// นำเข้าไลบรารีแจ้งเตือนท้องถิ่นของ Flutter
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// คลาสให้บริการแจ้งเตือนในแอป
class NotificationService {
  // สร้างตัวจัดการการแจ้งเตือน (plugin) ที่จะใช้ในทุกฟังก์ชันของคลาสนี้
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ฟังก์ชันเริ่มต้นระบบแจ้งเตือน ต้องเรียกใช้เมื่อเริ่มแอป
  Future<void> initialize() async {
    // ตั้งค่าเริ่มต้นสำหรับแอนดรอยด์ โดยใช้ไอคอนของแอปเป็นไอคอนแจ้งเตือน
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // รวมการตั้งค่าเริ่มต้นของทุกแพลตฟอร์ม (ตอนนี้มีแค่แอนดรอยด์)
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // เริ่มต้นปลั๊กอินแจ้งเตือนด้วยการตั้งค่าที่กำหนด
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // ฟังก์ชันแสดงการแจ้งเตือนบนอุปกรณ์
  Future<void> showNotification({
    required String title, // หัวข้อการแจ้งเตือน
    required String body, // เนื้อหาการแจ้งเตือน
    required int
    id, // รหัสเฉพาะสำหรับการแจ้งเตือนนี้ (ใช้แยกแยะการแจ้งเตือนต่างๆ)
  }) async {
    // กำหนดรายละเอียดการแจ้งเตือนสำหรับแอนดรอยด์
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'rfid_asset_channel', // รหัสช่องทางแจ้งเตือน (ช่วยจัดกลุ่มการแจ้งเตือน)
      'RFID Asset Notifications', // ชื่อช่องทางแจ้งเตือนที่ผู้ใช้จะเห็น
      importance: Importance.high, // ระดับความสำคัญสูง
      priority: Priority.high, // ลำดับความสำคัญสูง (แสดงทันที)
    );

    // รวมรายละเอียดการแจ้งเตือนของทุกแพลตฟอร์ม (ตอนนี้มีแค่แอนดรอยด์)
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // แสดงการแจ้งเตือนด้วยข้อมูลที่ได้รับ
    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }
}
