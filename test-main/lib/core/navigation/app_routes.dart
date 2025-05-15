import 'package:flutter/material.dart';
// นำเข้าด้วยเส้นทางแบบเต็ม และใช้ show เพื่อยืนยันว่านำเข้าถูกคลาส
import 'package:rfid_project/presentation/features/export/screens/export_confirmation_screen.dart'
    show ExportConfirmationScreen;
import 'package:rfid_project/presentation/features/export/screens/export_screen.dart'
    show ExportScreen;
import 'package:rfid_project/presentation/features/settings/screens/database_test_screen.dart';
import '../../presentation/features/assets/screens/asset_detail_screen.dart';
import '../../presentation/features/assets/screens/search_assets_screen.dart';
import '../../presentation/features/dashboard/screens/home_screen.dart';
import '../../presentation/features/rfid/screens/found_screen.dart';
import '../../presentation/features/rfid/screens/not_found_screen.dart';
import '../../presentation/features/rfid/screens/scan_rfid_screen.dart';
import '../../presentation/features/settings/screens/settings_screen.dart';
import '../../presentation/features/reports/screens/reports_screen.dart';
import '../constants/route_constants.dart';

class AppRoutes {
  // ประกาศชื่อเส้นทางต่างๆ โดยใช้ค่าจาก RouteConstants
  static const String home = RouteConstants.home; // เส้นทางไปหน้าหลัก
  static const String searchAssets =
      RouteConstants.searchAssets; // เส้นทางไปหน้าค้นหา
  static const String scanRfid = RouteConstants.scanRfid; // เส้นทางไปหน้าสแกน
  static const String reports =
      RouteConstants.reports; // เส้นทางไปหน้ารายงาน (เปลี่ยนจาก viewAssets)
  static const String export = RouteConstants.export; // เส้นทางไปหน้าส่งออก
  static const String found = RouteConstants.found; // เส้นทางไปหน้าพบสินทรัพย์
  static const String notFound =
      RouteConstants.notFound; // เส้นทางไปหน้าไม่พบสินทรัพย์
  static const String settings =
      RouteConstants.settings; // เส้นทางไปหน้าตั้งค่า
  static const String databaseTest = RouteConstants.databaseTest;
  static const String assetDetail =
      RouteConstants.assetDetail; // เส้นทางไปหน้ารายละเอียดสินทรัพย์เต็ม
  static const String exportConfirmation = '/exportConfirmation';

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
    // รับ arguments ที่ส่งมาพร้อมกับการนำทาง
    final args = routeSettings.arguments;

    // ตรวจสอบชื่อเส้นทางและสร้างหน้าจอที่เหมาะสม
    switch (routeSettings.name) {
      case databaseTest:
        return _createRouteWithoutAnimation(
          const DatabaseTestScreen(),
          routeSettings,
        );
      case home:
        return _createRouteWithoutAnimation(const HomeScreen(), routeSettings);
      case searchAssets:
        return _createRouteWithoutAnimation(
          const SearchAssetsScreen(),
          routeSettings,
        );
      case scanRfid:
        return _createRouteWithoutAnimation(
          const ScanRfidScreen(),
          routeSettings,
        );
      case reports:
        return _createRouteWithoutAnimation(
          const ReportsScreen(),
          routeSettings,
        );
      case export:
        return _createRouteWithoutAnimation(
          const ExportScreen(), // แก้ไขตัวสะกดให้ถูกต้อง
          routeSettings,
        );
      case assetDetail:
        return _createRouteWithoutAnimation(
          const AssetDetailScreen(),
          routeSettings,
        );
      case found:
        if (args is Map<String, dynamic>) {
          return _createRouteWithoutAnimation(
            const FoundScreen(),
            routeSettings,
          );
        }
        return _createRouteWithoutAnimation(
          const ScanRfidScreen(),
          routeSettings,
        );
      case notFound:
        return _createRouteWithoutAnimation(
          const NotFoundScreen(),
          routeSettings,
        );
      case settings:
        return _createRouteWithoutAnimation(
          const SettingsScreen(),
          routeSettings,
        );
      case exportConfirmation:
        // ใช้ Widget constructor แทนที่จะใช้ class อย่างเดียว
        return _createRouteWithoutAnimation(
          ExportConfirmationScreen(),
          routeSettings,
        );
      default:
        return _createRouteWithoutAnimation(const HomeScreen(), routeSettings);
    }
  }
}
