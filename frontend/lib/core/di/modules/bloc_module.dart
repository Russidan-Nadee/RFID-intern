// lib/core/di/modules/bloc_module.dart
import 'package:get_it/get_it.dart';
import 'package:rfid_project/domain/usecases/assets/bulk_update_assets_usecase.dart';
import '../../../domain/usecases/assets/get_assets_usecase.dart';
import '../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../domain/repositories/asset_repository.dart';
import '../../../presentation/features/search/blocs/asset_bloc.dart';
import '../../../presentation/features/dashboard/blocs/dashboard_bloc.dart';
import '../../../presentation/features/export/blocs/export_bloc.dart';
import '../../../presentation/features/main/blocs/navigation_bloc.dart';
import '../../../presentation/features/rfid/blocs/rfid_scan_provider.dart';
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
      () => ExportBloc(_getIt<GetAssetsUseCase>(), _getIt<AssetRepository>()),
    );

    // ลงทะเบียน RfidScanBloc
    _getIt.registerFactory<RfidScanProvider>(
      () => RfidScanProvider(
        _getIt<ScanRfidUseCase>(),
        _getIt<BulkUpdateAssetsUseCase>(),
      ),
    );

    _getIt.registerFactory<ReportsBloc>(
      () => ReportsBloc(_getIt<GetAssetsUseCase>()),
    );
  }
}
