// lib/presentation/features/export/screens/export_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../blocs/export_bloc.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../features/main/blocs/navigation_bloc.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _assetId;
  String? _assetUid;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // รับค่า arguments
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _assetId = args['assetId'];
          _assetUid = args['assetUid'];
        });
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 4) return; // ถ้าเป็นแท็บปัจจุบัน (Export) ไม่ต้องทำอะไร

    // ดึง NavigationBloc จาก Provider
    final navigationBloc = Provider.of<NavigationBloc>(context, listen: false);

    // อัปเดต index ใน NavigationBloc
    navigationBloc.setCurrentIndex(index);

    // ใช้ NavigationService เพื่อไปยังหน้าที่ต้องการ
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    // เพิ่มการอ่านค่า currentIndex จาก NavigationBloc
    final navigationBloc = Provider.of<NavigationBloc>(context);
    final currentIndex = navigationBloc.currentIndex;

    return ScreenContainer(
      appBar: AppBar(
        title: Text(
          _assetId != null ? 'Export Asset: $_assetId' : 'Export Assets Data',
        ),
        elevation: 0,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_assetId != null && _assetUid != null) ...[
                // แสดงข้อมูลที่รับมา
                Text('Asset ID: $_assetId', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Asset UID: $_assetUid', style: TextStyle(fontSize: 18)),
                SizedBox(height: 24),
                Text(
                  'CSV Export will be implemented soon...',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ] else
                Text(
                  'No specific asset selected for export',
                  style: TextStyle(fontSize: 18),
                ),
              SizedBox(height: 16),
              Text(
                'You can select an asset from Search to export individual data',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
