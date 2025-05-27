// Path: frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // เพิ่ม import นี้
import 'package:rfid_project/domain/service/auth_service.dart';
import 'package:rfid_project/presentation/features/rfid/bloc/rfid_scan_bloc.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/features/search/blocs/asset_bloc.dart';
import 'presentation/features/dashboard/blocs/dashboard_bloc.dart';
import 'presentation/features/export/blocs/export_bloc.dart';
import 'presentation/features/main/blocs/navigation_bloc.dart';
import 'presentation/features/settings/blocs/settings_bloc.dart';
import 'presentation/features/reports/blocs/reports_bloc.dart';
import 'package:provider/single_child_widget.dart';

void main() async {
  // ต้องเรียกก่อนเข้าถึง native code
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น dependency injection
  await _initializeDependencies();

  // เริ่มแอปพลิเคชัน
  runApp(const MyApp());
}

/// แยกการเริ่มต้น dependencies ออกมาเป็นเมธอดต่างหาก
/// เพื่อให้โค้ดอ่านง่ายและจัดการได้ง่าย
Future<void> _initializeDependencies() async {
  // เริ่มต้น DI container
  await DependencyInjection.init();

  // สามารถเพิ่มการกำหนดค่าอื่นๆ ได้ตรงนี้ เช่น
  // - การตั้งค่า Logging
  // - การตั้งค่า Analytics
  // - การตั้งค่า Local Storage
}

/// Root Widget ของแอปพลิเคชัน
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _createProviders(),
      child: MaterialApp(
        title: 'RFID Asset Management',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// แยกการสร้าง providers ออกมาเป็นเมธอดต่างหาก
  /// เพื่อให้โค้ดอ่านง่ายและจัดการได้ง่าย
  List<SingleChildWidget> _createProviders() {
    return [
      // NavigationBloc - ควบคุมการนำทางระหว่าง tabs
      ChangeNotifierProvider<NavigationBloc>(
        create: (_) => DependencyInjection.get<NavigationBloc>(),
      ),

      // DashboardBloc - จัดการข้อมูลหน้า Dashboard
      ChangeNotifierProvider<DashboardBloc>(
        create: (_) => DependencyInjection.get<DashboardBloc>(),
      ),

      // AssetBloc - จัดการข้อมูลสินทรัพย์
      ChangeNotifierProvider<AssetBloc>(
        create: (_) => DependencyInjection.get<AssetBloc>(),
      ),

      // ExportBloc - จัดการการส่งออกข้อมูล
      ChangeNotifierProvider<ExportBloc>(
        create: (_) => DependencyInjection.get<ExportBloc>(),
      ),

      // RfidScanBloc - จัดการการสแกน RFID (เปลี่ยนเป็น BlocProvider)
      BlocProvider<RfidScanBloc>(
        create: (_) => DependencyInjection.get<RfidScanBloc>(),
      ),

      // SettingsBloc - จัดการการตั้งค่าแอปพลิเคชัน
      ChangeNotifierProvider<SettingsBloc>(
        create: (_) => DependencyInjection.get<SettingsBloc>(),
      ),

      ChangeNotifierProvider<ReportsBloc>(
        create: (_) => DependencyInjection.get<ReportsBloc>(),
      ),

      ChangeNotifierProvider<AuthService>(
        create: (_) => DependencyInjection.get<AuthService>(),
      ),
    ];
  }
}
