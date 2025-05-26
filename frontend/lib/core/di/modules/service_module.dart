import 'package:get_it/get_it.dart';
import 'package:rfid_project/core/services/auth_service.dart';
import 'package:rfid_project/core/validation/asset_validator.dart';
import 'package:rfid_project/data/datasources/random_epc_datasource.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/repositories/auth_repository.dart';
import 'package:rfid_project/domain/usecases/assets/create_asset_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/find_asset_by_epc_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/generate_mock_asset_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import 'package:rfid_project/domain/usecases/export/prepare_export_columns_usecase.dart';
import 'package:rfid_project/domain/usecases/rfid/scan_rfid_usecase.dart';
import 'package:rfid_project/domain/usecases/assets/bulk_update_assets_usecase.dart';

class ServiceModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียนบริการต่างๆ
  Future<void> register() async {
    _getIt.registerLazySingleton(() => GetAssetsUseCase(_getIt()));

    _getIt.registerLazySingleton(() => PrepareExportColumnsUseCase());

    _getIt.registerLazySingleton<EpcDatasource>(
      () => RandomEpcDatasource(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(
      () => FindAssetByEpcUseCase(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(
      () => ScanRfidUseCase(
        _getIt<EpcDatasource>(),
        _getIt<FindAssetByEpcUseCase>(),
      ),
    );

    _getIt.registerLazySingleton(
      () => AssetValidator(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(
      () => GenerateMockAssetUseCase(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(
      () => CreateAssetUseCase(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(
      () => BulkUpdateAssetsUseCase(_getIt<AssetRepository>()),
    );

    _getIt.registerLazySingleton(() => AuthService(_getIt<AuthRepository>()));
  }
}
