import 'package:flutter/material.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import 'package:rfid_project/presentation/features/auth/screens/login_screen.dart';
import 'package:rfid_project/presentation/features/export/screens/export_confirmation_screen.dart'
    show ExportConfirmationScreen;
import 'package:rfid_project/presentation/features/export/screens/export_screen.dart'
    show ExportScreen;
import 'package:rfid_project/presentation/features/settings/screens/role_management_screen.dart';
import '../../presentation/features/search/screens/asset_detail_screen.dart';
import '../../presentation/features/search/screens/search_assets_screen.dart';
import '../../presentation/features/dashboard/screens/dashboard_screen.dart';
import '../../presentation/features/rfid/screens/scan_rfid_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/reports/screens/reports_screen.dart';
import '../constants/route_constants.dart';
import '../di/dependency_injection.dart';

class AppRoutes {
  // ประกาศชื่อเส้นทางต่างๆ โดยใช้ค่าจาก RouteConstants
  static const String home = RouteConstants.home;
  static const String searchAssets = RouteConstants.searchAssets;
  static const String scanRfid = RouteConstants.scanRfid;
  static const String reports = RouteConstants.reports;
  static const String export = RouteConstants.export;
  static const String settings = RouteConstants.settings;
  static const String assetDetail = RouteConstants.assetDetail;
  static const String exportConfirmation = '/exportConfirmation';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String roleManagement = '/roleManagement';

  // ฟังก์ชั่นสำหรับสร้าง Route ที่ไม่มีอนิเมชั่น
  static Route<dynamic> _createRouteWithoutAnimation(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _createRouteWithoutAnimation(
          const DashboardScreen(),
          routeSettings,
        );
      case searchAssets:
        return _createRouteWithoutAnimation(
          const SearchAssetsScreen(),
          routeSettings,
        );
      case scanRfid:
        return _createRouteWithoutAnimation(
          ScanRfidScreen(
            assetRepository: DependencyInjection.get<AssetRepository>(),
          ),
          routeSettings,
        );
      case reports:
        return _createRouteWithoutAnimation(
          ReportsScreen(
            getAssetsUseCase: DependencyInjection.get<GetAssetsUseCase>(),
          ),
          routeSettings,
        );
      case export:
        return _createRouteWithoutAnimation(
          const ExportScreen(),
          routeSettings,
        );
      case assetDetail:
        return _createRouteWithoutAnimation(
          AssetDetailScreen(
            assetRepository: DependencyInjection.get<AssetRepository>(),
          ),
          routeSettings,
        );
      case settings:
        return _createRouteWithoutAnimation(
          const SettingsScreen(),
          routeSettings,
        );
      case exportConfirmation:
        return _createRouteWithoutAnimation(
          ExportConfirmationScreen(),
          routeSettings,
        );
      case login:
        return _createRouteWithoutAnimation(const LoginScreen(), routeSettings);

      case roleManagement:
        return _createRouteWithoutAnimation(
          const RoleManagementScreen(),
          routeSettings,
        );

      default:
        return _createRouteWithoutAnimation(
          const DashboardScreen(),
          routeSettings,
        );
    }
  }
}