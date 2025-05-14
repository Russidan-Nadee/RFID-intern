// ไฟล์นี้เป็นจุดเริ่มต้นของแอพ

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/features/assets/blocs/asset_bloc.dart';
import 'presentation/features/dashboard/blocs/dashboard_bloc.dart';
import 'presentation/features/export/blocs/export_bloc.dart';
import 'presentation/features/main/blocs/navigation_bloc.dart';
import 'presentation/features/rfid/blocs/rfid_scan_bloc.dart';
import 'presentation/features/settings/blocs/settings_bloc.dart';
import 'domain/usecases/assets/get_assets_usecase.dart';
import 'domain/usecases/rfid/scan_rfid_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DependencyInjection.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AssetRepository>(
          create: (_) => DependencyInjection.getIt.get<AssetRepository>(),
        ),
        ChangeNotifierProvider(create: (_) => NavigationBloc()),
        ChangeNotifierProvider(
          create:
              (_) =>
                  AssetBloc(DependencyInjection.getIt.get<GetAssetsUseCase>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => DashboardBloc(
                DependencyInjection.getIt.get<GetAssetsUseCase>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (_) =>
                  ExportBloc(DependencyInjection.getIt.get<GetAssetsUseCase>()),
        ),
        ChangeNotifierProvider(
          create:
              (_) => RfidScanBloc(
                DependencyInjection.getIt.get<ScanRfidUseCase>(),
              ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsBloc(DependencyInjection.getIt.get()),
        ),
      ],
      child: MaterialApp(
        title: 'RFID Asset Management',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
