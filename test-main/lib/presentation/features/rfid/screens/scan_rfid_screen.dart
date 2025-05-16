// ใน lib/presentation/features/rfid/screens/scan_rfid_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../widgets/asset_info_card.dart';
import '../widgets/asset_not_found_card.dart';
import '../widgets/unknown_epc_card.dart';
import '../../assets/screens/asset_creation_preview_screen.dart';
import '../../../../domain/usecases/assets/generate_asset_from_epc_usecase.dart';
import '../../../../core/di/dependency_injection.dart';

class ScanRfidScreen extends StatefulWidget {
  const ScanRfidScreen({Key? key}) : super(key: key);

  @override
  State<ScanRfidScreen> createState() => _ScanRfidScreenState();
}

class _ScanRfidScreenState extends State<ScanRfidScreen> {
  int _selectedIndex = 2; // Index for the Scan tab
  final _generateAssetUseCase =
      DependencyInjection.get<GenerateAssetFromEpcUseCase>();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  void _showAssetPreview(BuildContext context, String epc) async {
    // สร้างข้อมูลตัวอย่างจาก EPC แต่ยังไม่บันทึกลงฐานข้อมูล
    final previewAsset = await _generateAssetUseCase.generatePreview(epc);

    if (!mounted) return;

    // นำทางไปยังหน้าตัวอย่างข้อมูล
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AssetCreationPreviewScreen(
              asset: previewAsset,
              onCreatePressed: () {
                // ตรงนี้ยังไม่ทำอะไร ตามคำสั่งให้เป็นปุ่มเปล่าๆ
                print(
                  'Create Asset button pressed - no action implemented yet',
                );
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('RFID Scanner'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<RfidScanBloc>(
        builder: (context, bloc, child) {
          // แสดงผลตามสถานะการสแกน
          switch (bloc.status) {
            case RfidScanStatus.scanning:
              return _buildScanningView();
            case RfidScanStatus.scanned:
              return _buildScannedResultView(bloc, context);
            case RfidScanStatus.error:
              return _buildErrorView(bloc);
            case RfidScanStatus.initial:
            default:
              return _buildInitialView(bloc, context);
          }
        },
      ),
    );
  }

  // หน้าจอเริ่มต้น - แสดงปุ่ม Scan
  Widget _buildInitialView(RfidScanBloc bloc, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ไอคอนและข้อความ
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Theme.of(context).primaryColor.withAlpha(100),
          ),
          const SizedBox(height: 20),
          Text(
            'กดปุ่ม SCAN เพื่อเริ่มสแกน RFID',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 40),

          // ปุ่ม Scan
          PrimaryButton(
            text: 'SCAN',
            icon: Icons.qr_code_scanner,
            onPressed: () => bloc.performScan(context),
          ),
        ],
      ),
    );
  }

  // หน้าจอขณะกำลังสแกน - แสดง Loading
  Widget _buildScanningView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          const SizedBox(height: 20),
          Text(
            'กำลังสแกน...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text('กรุณารอสักครู่', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // แก้ไขส่วนที่แสดงผลลัพธ์การสแกน
  // แก้ไขส่วนที่แสดงผลลัพธ์การสแกน
  Widget _buildScannedResultView(RfidScanBloc bloc, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อผลการสแกน
          const Text(
            'ผลการสแกน RFID',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ตรงนี้จะแสดงผลการสแกนแต่ละรายการ
          if (bloc.scanResults.isEmpty)
            const AssetNotFoundCard()
          else
            Column(
              children:
                  bloc.scanResults.map((result) {
                    if (result.epc == null || result.epc!.isEmpty) {
                      // กรณีไม่มี EPC
                      return const AssetNotFoundCard();
                    } else if (result.asset != null) {
                      // กรณีมี EPC และพบข้อมูลในฐานข้อมูล
                      return AssetInfoCard(
                        asset: result.asset!,
                        onViewDetails:
                            () => Navigator.pushNamed(
                              context,
                              '/assetDetail',
                              arguments: {'guid': result.asset!.tagId},
                            ),
                      );
                    } else {
                      // กรณีมี EPC แต่ไม่พบข้อมูลในฐานข้อมูล
                      return UnknownEpcCard(
                        epc: result.epc!,
                        generatedAsset: null, // ยังไม่มีข้อมูลที่สร้าง
                        onTap: () => _showAssetPreview(context, result.epc!),
                      );
                    }
                  }).toList(),
            ),

          const SizedBox(height: 24),

          // ปุ่มสแกนอีกครั้ง
          Center(
            child: PrimaryButton(
              text: 'สแกนอีกครั้ง',
              icon: Icons.refresh,
              onPressed: () => bloc.resetScan(),
            ),
          ),
        ],
      ),
    );
  }

  // หน้าจอแสดงข้อผิดพลาด
  Widget _buildErrorView(RfidScanBloc bloc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              bloc.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'ลองอีกครั้ง',
              icon: Icons.refresh,
              onPressed: () => bloc.resetScan(),
            ),
          ],
        ),
      ),
    );
  }
}
