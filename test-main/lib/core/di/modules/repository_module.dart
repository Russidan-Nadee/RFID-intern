import 'package:get_it/get_it.dart';
import '../../../domain/repositories/asset_repository.dart';
import '../../../data/repositories/asset_repository_impl.dart';
import '../../../data/datasources/remote/api_service.dart';

// คลาสโมดูลคลังข้อมูล - ใช้ลงทะเบียนคลังข้อมูลทั้งหมดในแอป
class RepositoryModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนคลังข้อมูล
  Future<void> register() async {
    // ลงทะเบียน ApiService ถ้ายังไม่ถูกลงทะเบียนมาก่อน
    if (!_getIt.isRegistered<ApiService>()) {
      _getIt.registerLazySingleton<ApiService>(() => ApiService());
    }

    // ลงทะเบียน AssetRepository ถ้ายังไม่ถูกลงทะเบียนมาก่อน
    if (!_getIt.isRegistered<AssetRepository>()) {
      _getIt.registerLazySingleton<AssetRepository>(
        () => AssetRepositoryImpl(_getIt<ApiService>()),
      );
    }
  }
}
