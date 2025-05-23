import 'package:get_it/get_it.dart';
import '../../../domain/repositories/asset_repository.dart';
import '../../../domain/repositories/auth_repository.dart'; // เพิ่มบรรทัดนี้
import '../../../data/repositories/asset_repository_impl.dart';
import '../../../data/repositories/auth_repository_impl.dart'; // เพิ่มบรรทัดนี้
import '../../../data/datasources/remote/api_service.dart';

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

    // เพิ่มส่วนนี้ - ลงทะเบียน AuthRepository
    if (!_getIt.isRegistered<AuthRepository>()) {
      _getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(_getIt<ApiService>()),
      );
    }
  }
}
