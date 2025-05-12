// ไฟล์นี้สร้างโมดูลฐานข้อมูลสำหรับเชื่อมต่อกับ SQLite และ MySQL

// นำเข้าไลบรารี get_it สำหรับจัดการการสร้างออบเจกต์
import 'package:get_it/get_it.dart';
// นำเข้าตัวช่วยจัดการฐานข้อมูล SQLite
import '../../../data/datasources/local/database_helper.dart';
// นำเข้าตัวช่วยจัดการฐานข้อมูล MySQL
import '../../../data/datasources/remote/mysql_data_source.dart';
// นำเข้าการตั้งค่าแอป
import '../../../core/config/app_config.dart';

// คลาสโมดูลฐานข้อมูล - ใช้สำหรับลงทะเบียนส่วนที่เกี่ยวกับฐานข้อมูล
class DatabaseModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการพึ่งพา (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนตัวช่วยฐานข้อมูล
  Future<void> register() async {
    // ลงทะเบียน DatabaseHelper แบบ Lazy Singleton
    // แบบ Lazy แปลว่าสร้างเมื่อมีการเรียกใช้ครั้งแรกเท่านั้น
    // แบบ Singleton แปลว่าทั้งแอปใช้ตัวเดียวกัน ไม่ต้องสร้างหลายตัว
    _getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

    // ลงทะเบียน MySqlDataSource แบบ Lazy Singleton
    // เฉพาะเมื่อตั้งค่าให้ใช้ฐานข้อมูลระยะไกล
    if (AppConfig.useRemoteDatabase) {
      _getIt.registerLazySingleton(() => MySqlDataSource());
    }
  }
}
