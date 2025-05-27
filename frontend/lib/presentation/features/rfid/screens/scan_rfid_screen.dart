import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/usecases/assets/generate_mock_asset_usecase.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/app_bottom_navigation.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import 'package:rfid_project/presentation/features/rfid/widgets/rfid_scan_result_cards.dart';

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
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
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
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Consumer<RfidScanBloc>(
            builder: (context, bloc, child) {
              return IconButton(
                onPressed:
                    bloc.status == RfidScanStatus.scanning
                        ? null
                        : () => _performRefreshScan(bloc),
                icon: Icon(
                  Icons.refresh,
                  color:
                      bloc.status == RfidScanStatus.scanning
                          ? Colors.grey
                          : Colors.deepPurple,
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<RfidScanBloc>(
        builder: (context, bloc, child) {
          switch (bloc.status) {
            case RfidScanStatus.initial:
              return _buildInitialView(bloc);
            case RfidScanStatus.scanning:
              return _buildScanningView();
            case RfidScanStatus.scanned:
              return _buildScannedResultView(bloc);
            case RfidScanStatus.error:
              return _buildErrorView(bloc);
          }
        },
      ),
    );
  }

  Widget _buildInitialView(RfidScanBloc bloc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.nfc, size: 60, color: Colors.deepPurple.shade400),
          ),
          const SizedBox(height: 32),
          Text(
            'RFID Scanner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'กดปุ่ม SCAN เพื่อเริ่มสแกน RFID',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: bloc.performScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SCAN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildScannedResultView(RfidScanBloc bloc) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'ผลการสแกน RFID (${bloc.scanResults.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              bloc.hasScanResults
                  ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bloc.scanResults.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final result = bloc.scanResults[index];
                      return RfidScanResultCards(
                        result: result,
                        generateAssetUseCase: widget.generateAssetUseCase,
                        assetRepository: widget.assetRepository,
                      );
                    },
                  )
                  : const Center(
                    child: Text(
                      'ไม่พบผลลัพธ์การสแกน',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildErrorView(RfidScanBloc bloc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 24),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              bloc.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: bloc.performScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
  }

  void _performRefreshScan(RfidScanBloc bloc) {
    bloc.performScan();
  }
}
