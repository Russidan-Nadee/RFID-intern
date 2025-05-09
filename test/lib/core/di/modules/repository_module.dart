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

// คลาสโมดูลคลังข้อมูล - ใช้ลงทะเบียนคลังข้อมูลทั้งหมดในแอป
class RepositoryModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนคลังข้อมูล
  Future<void> register() async {
    // ลงทะเบียน AssetRepository แบบ Lazy Singleton
    // แบบ Lazy แปลว่าสร้างเมื่อมีการเรียกใช้ครั้งแรกเท่านั้น
    // โดยอินเทอร์เฟซ AssetRepository จะใช้งานผ่าน AssetRepositoryImpl
    // _getIt() เป็นการดึงสิ่งที่ลงทะเบียนไว้แล้ว (น่าจะเป็น DatabaseHelper) มาใช้
    _getIt.registerLazySingleton<AssetRepository>(
      () => AssetRepositoryImpl(_getIt()),
    );

    // ลงทะเบียน RandomAssetRepository แบบ Lazy Singleton
    // ไม่จำเป็นต้องมีพารามิเตอร์เพราะสร้างข้อมูลสุ่มเอง
    _getIt.registerLazySingleton<RandomAssetRepository>(
      () => RandomAssetRepositoryImpl(),
    );
  }
}
