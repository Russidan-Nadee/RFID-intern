// ไฟล์นี้จัดการการลงทะเบียนส่วนต่างๆ ของแอปให้สามารถใช้งานร่วมกันได้

// นำเข้าไลบรารี get_it ซึ่งช่วยในการจัดการการพึ่งพากันของชิ้นส่วนต่างๆ ในแอป
import 'package:get_it/get_it.dart';
import 'package:rfid_project/core/di/modules/bloc_module.dart';
// นำเข้าโมดูลย่อยที่จะลงทะเบียน
import 'package:rfid_project/core/di/modules/database_module.dart'; // โมดูลฐานข้อมูล
import 'package:rfid_project/core/di/modules/repository_module.dart'; // โมดูลคลังข้อมูล
import 'package:rfid_project/core/di/modules/service_module.dart'; // โมดูลบริการ

// คลาสสำหรับจัดการการลงทะเบียนส่วนประกอบต่างๆ ของแอป
class DependencyInjection {
  // สร้างตัวแปร getIt เพื่อใช้เป็นจุดศูนย์กลางในการเข้าถึงส่วนต่างๆ ของแอป
  static final GetIt getIt = GetIt.instance;

  // ฟังก์ชันเริ่มต้นที่ลงทะเบียนทุกโมดูล
  static Future<void> init() async {
    // ลงทะเบียนโมดูลฐานข้อมูล (เช่น SQLite) ก่อน
    // เพราะส่วนอื่นๆ จะต้องใช้การเชื่อมต่อฐานข้อมูล
    await DatabaseModule().register();

    // ลงทะเบียนโมดูลคลังข้อมูล ซึ่งใช้ในการติดต่อกับฐานข้อมูล
    // โมดูลนี้จะใช้ DatabaseModule ที่ลงทะเบียนก่อนหน้า
    await RepositoryModule().register();

    // ลงทะเบียนโมดูลบริการ ซึ่งมีฟังก์ชันการทำงานระดับสูง
    // โมดูลนี้จะใช้ RepositoryModule ที่ลงทะเบียนก่อนหน้า
    await ServiceModule().register();

    // ลงทะเบียนโมดูล Bloc สำหรับการจัดการสถานะของแอป
    // โมดูลนี้จะใช้ ServiceModule ที่ลงทะเบียนก่อนหน้า
    await BlocModule().register();
  }

  // เมธอดสำหรับดึง dependency ตาม type ที่ระบุ
  static T get<T extends Object>() {
    return getIt<T>();
  }

  // เมธอดสำหรับตรวจสอบว่ามีการลงทะเบียน dependency นั้นแล้วหรือไม่
  static bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }

  // เมธอดสำหรับลงทะเบียน dependency แบบ singleton (สร้างครั้งเดียว ใช้ตลอด)
  static void registerSingleton<T extends Object>(T instance) {
    if (!isRegistered<T>()) {
      getIt.registerSingleton<T>(instance);
    }
  }

  // เมธอดสำหรับลงทะเบียน dependency แบบ lazy singleton (สร้างเมื่อต้องการใช้)
  static void registerLazySingleton<T extends Object>(
    T Function() factoryFunc,
  ) {
    if (!isRegistered<T>()) {
      getIt.registerLazySingleton<T>(factoryFunc);
    }
  }

  // เมธอดสำหรับลงทะเบียน dependency แบบ factory (สร้างใหม่ทุกครั้งที่เรียกใช้)
  static void registerFactory<T extends Object>(T Function() factoryFunc) {
    if (!isRegistered<T>()) {
      getIt.registerFactory<T>(factoryFunc);
    }
  }

  // เมธอดสำหรับรีเซ็ต (ลบการลงทะเบียนทั้งหมด)
  static Future<void> reset() async {
    await getIt.reset();
  }
}
