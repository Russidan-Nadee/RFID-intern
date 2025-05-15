// lib/core/di/modules/bloc_module.dart
import 'package:get_it/get_it.dart';
import 'package:rfid_project/domain/usecases/export/prepare_export_columns_usecase.dart';
import '../../../domain/usecases/assets/get_assets_usecase.dart';
import '../../../domain/usecases/category/add_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../domain/repositories/asset_repository.dart';
import '../../../domain/usecases/assets/update_asset_usecase.dart';
import '../../../presentation/features/assets/blocs/asset_bloc.dart';
import '../../../presentation/features/dashboard/blocs/dashboard_bloc.dart';
import '../../../presentation/features/export/blocs/export_bloc.dart';
import '../../../presentation/features/main/blocs/navigation_bloc.dart';
import '../../../presentation/features/rfid/blocs/rfid_scan_bloc.dart';
import '../../../presentation/features/settings/blocs/settings_bloc.dart';
import '../../../presentation/features/settings/blocs/category_bloc.dart';
import '../../../presentation/features/reports/blocs/reports_bloc.dart';

class BlocModule {
  // สร้างตัวแปรเพื่อเข้าถึงตัวจัดการการเชื่อมโยง (GetIt)
  final GetIt _getIt = GetIt.instance;

  // ฟังก์ชันลงทะเบียน Bloc ทั้งหมด
  Future<void> register() async {
    // ลงทะเบียน NavigationBloc
    _getIt.registerFactory<NavigationBloc>(() => NavigationBloc());

    // ลงทะเบียน AssetBloc
    _getIt.registerFactory<AssetBloc>(
      () => AssetBloc(_getIt<GetAssetsUseCase>()),
    );

    // ลงทะเบียน DashboardBloc
    _getIt.registerFactory<DashboardBloc>(
      () => DashboardBloc(_getIt<GetAssetsUseCase>()),
    );

    // ลงทะเบียน ExportBloc
    _getIt.registerFactory<ExportBloc>(
      () => ExportBloc(
        _getIt<GetAssetsUseCase>(),
        _getIt<AssetRepository>(),
        _getIt<PrepareExportColumnsUseCase>(),
      ),
    );

    // ลงทะเบียน RfidScanBloc
    _getIt.registerFactory<RfidScanBloc>(
      () => RfidScanBloc(_getIt<ScanRfidUseCase>()),
    );

    // ลงทะเบียน SettingsBloc
    _getIt.registerFactory<SettingsBloc>(
      () => SettingsBloc(_getIt<AssetRepository>()),
    );

    // ลงทะเบียน CategoryBloc
    _getIt.registerFactory<CategoryBloc>(
      () => CategoryBloc(
        _getIt<GetCategoriesUseCase>(),
        _getIt<AddCategoryUseCase>(),
        _getIt<UpdateCategoryUseCase>(),
        _getIt<DeleteCategoryUseCase>(),
      ),
    );

    // ลงทะเบียน ReportsBloc
    _getIt.registerFactory<ReportsBloc>(
      () => ReportsBloc(_getIt<GetAssetsUseCase>()),
    );
  }
}
