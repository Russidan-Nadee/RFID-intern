// ไฟล์นี้สร้างโมดูลฐานข้อมูลสำหรับเชื่อมต่อกับ API

// นำเข้าไลบรารี get_it สำหรับจัดการการสร้างออบเจกต์
import 'package:get_it/get_it.dart';
// นำเข้า API Service
import '../../../data/datasources/remote/api_service.dart';

// คลาสโมดูลฐานข้อมูล - ใช้สำหรับลงทะเบียนส่วนที่เกี่ยวกับฐานข้อมูล
class DatabaseModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการพึ่งพา (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนตัวช่วยฐานข้อมูล
  Future<void> register() async {
    // ลงทะเบียน ApiService แบบ Lazy Singleton
    _getIt.registerLazySingleton<ApiService>(() => ApiService());
  }
}
