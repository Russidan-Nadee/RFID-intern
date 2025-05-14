import 'package:get_it/get_it.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import 'package:rfid_project/domain/usecases/category/add_category_usecase.dart';
import 'package:rfid_project/domain/usecases/category/delete_category_usecase.dart';
import 'package:rfid_project/domain/usecases/category/get_categories_usecase.dart';
import 'package:rfid_project/domain/usecases/category/update_category_usecase.dart';
import 'package:rfid_project/domain/usecases/rfid/scan_rfid_usecase.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/presentation/features/assets/blocs/asset_bloc.dart';
import 'package:rfid_project/presentation/features/dashboard/blocs/dashboard_bloc.dart';
import 'package:rfid_project/presentation/features/export/blocs/export_bloc.dart';
import 'package:rfid_project/presentation/features/main/blocs/navigation_bloc.dart';
import 'package:rfid_project/presentation/features/rfid/blocs/rfid_scan_bloc.dart';
import 'package:rfid_project/presentation/features/settings/blocs/settings_bloc.dart';
import 'package:rfid_project/presentation/features/settings/blocs/category_bloc.dart';

class BlocModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียน Bloc ทั้งหมด
  Future<void> register() async {
    // ลงทะเบียน NavigationBloc
    _getIt.registerFactory(() => NavigationBloc());

    // ลงทะเบียน AssetBloc
    _getIt.registerFactory(() => AssetBloc(_getIt<GetAssetsUseCase>()));

    // ลงทะเบียน DashboardBloc
    _getIt.registerFactory(() => DashboardBloc(_getIt<GetAssetsUseCase>()));

    // ลงทะเบียน ExportBloc
    _getIt.registerFactory(
      () => ExportBloc(_getIt<GetAssetsUseCase>(), _getIt<AssetRepository>()),
    );

    // ลงทะเบียน RfidScanBloc - ใช้เฉพาะ ScanRfidUseCase
    _getIt.registerFactory(() => RfidScanBloc(_getIt<ScanRfidUseCase>()));

    // ลงทะเบียน SettingsBloc
    _getIt.registerFactory(() => SettingsBloc(_getIt<AssetRepository>()));

    // ลงทะเบียน CategoryBloc
    _getIt.registerFactory(
      () => CategoryBloc(
        _getIt<GetCategoriesUseCase>(),
        _getIt<AddCategoryUseCase>(),
        _getIt<UpdateCategoryUseCase>(),
        _getIt<DeleteCategoryUseCase>(),
      ),
    );
  }
}
