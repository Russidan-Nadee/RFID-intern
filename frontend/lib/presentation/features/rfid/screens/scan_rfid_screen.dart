import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/usecases/assets/generate_mock_asset_usecase.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../widgets/asset_info_card.dart';
import '../widgets/asset_not_found_card.dart';
import '../widgets/unknown_epc_card.dart';
import '../../assets/screens/asset_creation_preview_screen.dart';

class ScanRfidScreen extends StatefulWidget {
  final GenerateMockAssetUseCase generateAssetUseCase;
  final AssetRepository assetRepository;

  const ScanRfidScreen({
    Key? key,
    required this.generateAssetUseCase,
    required this.assetRepository,
  }) : super(key: key);

  @override
  State<ScanRfidScreen> createState() => _ScanRfidScreenState();
}

class _ScanRfidScreenState extends State<ScanRfidScreen> {
  int _selectedIndex = 2; // Index for the Scan tab

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  void _showAssetPreview(BuildContext context, String epc) async {
    // สร้างข้อมูลตัวอย่างจาก EPC แต่ยังไม่บันทึกลงฐานข้อมูล
    final previewAsset = await widget.generateAssetUseCase.generatePreview(epc);

    if (!mounted) return;

    // นำทางไปยังหน้าตัวอย่างข้อมูล
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AssetCreationPreviewScreen(
              asset: previewAsset,
              assetRepository: widget.assetRepository,
              onCreatePressed: () {
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
        title: const Text(
          'RFID Scanner',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // ไม่มีเงาที่ AppBar
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

  Widget _buildInitialView(RfidScanBloc bloc, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ไอคอนและข้อความ
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
              // ไม่มีเงา
            ),
            child: Icon(
              Icons.wifi_tethering,
              size: 40,
              color: Colors.deepPurple.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'กดปุ่ม SCAN เพื่อเริ่มสแกน RFID',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 32),

          // ปุ่ม Scan
          PrimaryButton(
            text: 'SCAN',
            icon: Icons.wifi_tethering,
            color: Colors.deepPurple.shade50,
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
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              color: Colors.deepPurple.shade400,
              strokeWidth: 6,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'กำลังสแกน...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณารอสักครู่',
            style: TextStyle(color: Colors.grey[600], fontSize: 15),
          ),
        ],
      ),
    );
  }

  /* Path: lib/presentation/features/rfid/screens/scan_rfid_screen.dart */

  // แก้ไขในส่วนที่แสดงผลลัพธ์การสแกน โดยลบ Container ที่ซ้อนกัน
  Widget _buildScannedResultView(RfidScanBloc bloc, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อผลการสแกน
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_tethering,
                  color: Colors.deepPurple.shade600,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'ผลการสแกน RFID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                // แสดงจำนวนผลลัพธ์
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bloc.scanResults.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ตรงนี้จะแสดงผลการสแกนแต่ละรายการ
          if (bloc.scanResults.isEmpty)
            const AssetNotFoundCard()
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: bloc.scanResults.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final result = bloc.scanResults[index];

                if (result.epc == null || result.epc!.isEmpty) {
                  // กรณีไม่มี EPC - ใช้ Widget โดยตรงไม่ห่อด้วย Container
                  return const AssetNotFoundCard();
                } else if (result.asset != null) {
                  // กรณีมี EPC และพบข้อมูลในฐานข้อมูล - ใช้ Widget โดยตรงไม่ห่อด้วย Container
                  return AssetInfoCard(
                    asset: result.asset!,
                    onViewDetails:
                        () => Navigator.pushNamed(
                          context,
                          '/assetDetail',
                          arguments: {'tagId': result.asset!.tagId},
                        ),
                  );
                } else {
                  // กรณีมี EPC แต่ไม่พบข้อมูลในฐานข้อมูล - ใช้ Widget โดยตรงไม่ห่อด้วย Container
                  return UnknownEpcCard(
                    epc: result.epc!,
                    generatedAsset: null,
                    onTap: () => _showAssetPreview(context, result.epc!),
                  );
                }
              },
            ),

          const SizedBox(height: 24),

          // ปุ่มสแกนอีกครั้ง
          Center(
            child: PrimaryButton(
              text: 'สแกนอีกครั้ง',
              icon: Icons.refresh,
              color: Colors.deepPurple.shade50,
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(35),
                // ไม่มีเงา
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
                // ไม่มีเงา
              ),
              child: Text(
                bloc.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.red.shade800),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'ลองอีกครั้ง',
              icon: Icons.refresh,
              color: Colors.red.shade700,
              onPressed: () => bloc.resetScan(),
            ),
          ],
        ),
      ),
    );
  }
}
