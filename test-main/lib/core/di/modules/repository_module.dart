// ไฟล์นี้ลงทะเบียนคลังข้อมูล (Repository) ที่ใช้จัดการข้อมูลสินทรัพย์

// นำเข้าไลบรารี get_it สำหรับจัดการการเชื่อมโยงส่วนต่างๆ ในแอป
import 'package:get_it/get_it.dart';
// นำเข้าการใช้งานจริงของคลังข้อมูลสินทรัพย์
import '../../../data/repositories/asset_repository_impl.dart';
// นำเข้าอินเทอร์เฟซ (สัญญา) ของคลังข้อมูลสินทรัพย์
import '../../../domain/repositories/asset_repository.dart';
// นำเข้า repository ใหม่สำหรับข้อมูลสุ่ม
import '../../../data/repositories/random_asset_repository_impl.dart';
import '../../../domain/repositories/random_asset_repository.dart';
// นำเข้า MySQL Data Source
import '../../../data/datasources/remote/mysql_data_source.dart';
// นำเข้าการตั้งค่าแอป
import '../../../core/config/app_config.dart';

// คลาสโมดูลคลังข้อมูล - ใช้ลงทะเบียนคลังข้อมูลทั้งหมดในแอป
class RepositoryModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนคลังข้อมูล
  Future<void> register() async {
    // ลงทะเบียน AssetRepository แบบ Lazy Singleton
    if (AppConfig.useRemoteDatabase) {
      // กรณีใช้ MySQL: ส่งทั้ง Database Helper และ MySQL Data Source
      _getIt.registerLazySingleton<AssetRepository>(
        () => AssetRepositoryImpl(
          _getIt(), // DatabaseHelper
          _getIt<MySqlDataSource>(), // MySQL Data Source
        ),
      );
    } else {
      // กรณีใช้ SQLite: ส่งเฉพาะ Database Helper
      _getIt.registerLazySingleton<AssetRepository>(
        () => AssetRepositoryImpl(_getIt()),
      );
    }

    // ลงทะเบียน RandomAssetRepository แบบ Lazy Singleton
    // ไม่จำเป็นต้องมีพารามิเตอร์เพราะสร้างข้อมูลสุ่มเอง
    _getIt.registerLazySingleton<RandomAssetRepository>(
      () => RandomAssetRepositoryImpl(),
    );
  }
}
