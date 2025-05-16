import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../widgets/asset_info_card.dart';
import '../widgets/asset_not_found_card.dart';

class ScanRfidScreen extends StatefulWidget {
  const ScanRfidScreen({Key? key}) : super(key: key);

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

  // หน้าจอแสดงผลลัพธ์การสแกน
  Widget _buildScannedResultView(RfidScanBloc bloc, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนแสดง EPC
          _buildEpcCard(bloc),

          const SizedBox(height: 16),

          // ส่วนแสดงข้อมูลสินทรัพย์ (ถ้าพบ)
          if (bloc.isAssetFound)
            AssetInfoCard(
              asset: bloc.scannedAsset!,
              onViewDetails:
                  () => bloc.navigateToAssetDetail(context, bloc.scannedAsset!),
            )
          else
            const AssetNotFoundCard(),

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

  // การ์ดแสดง EPC
  Widget _buildEpcCard(RfidScanBloc bloc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'EPC ที่สแกนได้:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              bloc.scannedEpc ?? 'ไม่พบ EPC',
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
          ],
        ),
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
