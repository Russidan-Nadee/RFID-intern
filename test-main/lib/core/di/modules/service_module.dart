import 'package:get_it/get_it.dart';
import 'package:rfid_project/core/services/rfid_service.dart';
import 'package:rfid_project/data/datasources/remote/real_rfid_service.dart';
import 'package:rfid_project/domain/usecases/assets/create_asset_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/search_asset_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/update_asset_usecase.dart';
import 'package:rfid_project/domain/usecases/rfid/scan_rfid_usecase.dart';

// คลาสโมดูลบริการ - ใช้ลงทะเบียนการทำงานระดับสูง (UseCase) ในแอป
class ServiceModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนบริการต่างๆ
  Future<void> register() async {
    // ลงทะเบียน RFID Service จริง
    _getIt.registerLazySingleton<RfidService>(() => RealRfidService());

    // ลงทะเบียน UseCase ต่างๆ

    // ลงทะเบียน UseCase สำหรับสแกน RFID
    _getIt.registerLazySingleton(() => ScanRfidUseCase(_getIt(), _getIt()));

    // ลงทะเบียน UseCase สำหรับดึงข้อมูลสินทรัพย์ทั้งหมด
    _getIt.registerLazySingleton(() => GetAssetsUseCase(_getIt()));

    // ลงทะเบียน UseCase สำหรับค้นหาสินทรัพย์
    _getIt.registerLazySingleton(() => SearchAssetUseCase(_getIt()));

    // ลงทะเบียน UseCase สำหรับอัปเดตข้อมูลสินทรัพย์
    _getIt.registerLazySingleton(() => UpdateAssetUseCase(_getIt()));

    // ลงทะเบียน UseCase สำหรับสร้างสินทรัพย์ใหม่
    _getIt.registerLazySingleton(() => CreateAssetUseCase(_getIt()));
  }
}
