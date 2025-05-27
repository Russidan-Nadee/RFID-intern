// Path: frontend/lib/presentation/features/rfid/screens/scan_rfid_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/usecases/assets/generate_mock_asset_usecase.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/app_bottom_navigation.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/screen_container.dart';
import 'package:rfid_project/core/navigation/rfid_navigation_service.dart';
import 'package:rfid_project/presentation/features/rfid/bloc/rfid_scan_bloc.dart';
import 'package:rfid_project/presentation/features/rfid/bloc/rfid_scan_state.dart';
import '../widgets/rfid_scan_result_cards.dart';

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
          BlocBuilder<RfidScanBloc, RfidScanState>(
            builder: (context, state) {
              return IconButton(
                onPressed:
                    state is RfidScanScanning
                        ? null
                        : () =>
                            context.read<RfidScanBloc>().refreshScanResults(),
                icon: Icon(
                  Icons.refresh,
                  color:
                      state is RfidScanScanning
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
      child: BlocListener<RfidScanBloc, RfidScanState>(
        listener: (context, state) {
          // Handle navigation events
          if (state is NavigateToAssetDetail) {
            _handleAssetDetailNavigation(state.asset);
          } else if (state is NavigateToAssetCreation) {
            _handleAssetCreationNavigation(state.epc);
          } else if (state is ShowErrorMessage) {
            RfidNavigationService.showError(context, state.errorMessage);
          } else if (state is ShowSuccessMessage) {
            RfidNavigationService.showSuccess(context, state.message);
          }
        },
        child: BlocBuilder<RfidScanBloc, RfidScanState>(
          builder: (context, state) {
            if (state is RfidScanInitial) {
              return _buildInitialView();
            } else if (state is RfidScanScanning) {
              return _buildScanningView();
            } else if (state is RfidScanScanned) {
              return _buildScannedResultView(state);
            } else if (state is RfidScanError) {
              return _buildErrorView(state);
            }
            return _buildInitialView(); // Fallback
          },
        ),
      ),
    );
  }

  Widget _buildInitialView() {
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
            onPressed: () => context.read<RfidScanBloc>().performScan(),
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

  Widget _buildScannedResultView(RfidScanScanned state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.deepPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'ผลการสแกน RFID (${state.scanResults.length})',
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
              state.hasScanResults
                  ? ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.scanResults.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final result = state.scanResults[index];
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

  Widget _buildErrorView(RfidScanError state) {
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
              state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<RfidScanBloc>().performScan(),
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

  // Handle navigation to asset detail
  Future<void> _handleAssetDetailNavigation(asset) async {
    final result = await RfidNavigationService.navigateToAssetDetail(
      context,
      asset,
    );

    if (!mounted) return;

    if (result != null && result['updated'] == true) {
      context.read<RfidScanBloc>().updateCardStatus(
        result['tagId'],
        result['newStatus'],
      );
    }
  }

  // Handle navigation to asset creation
  Future<void> _handleAssetCreationNavigation(String epc) async {
    final result = await RfidNavigationService.navigateToAssetCreation(
      context,
      epc,
      widget.generateAssetUseCase,
      widget.assetRepository,
    );

    if (!mounted) return;

    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final newAsset = await widget.assetRepository.findAssetByEpc(epc);

        if (newAsset != null && mounted) {
          context.read<RfidScanBloc>().updateUnknownEpcToAsset(epc, newAsset);

          RfidNavigationService.showSuccess(
            context,
            'สร้าง ${newAsset.itemName} สำเร็จ',
          );
        } else if (mounted) {
          RfidNavigationService.showSnackBarWithAction(
            context,
            'สร้างสำเร็จแต่ไม่สามารถอัปเดตหน้าจอได้ กรุณา refresh',
            'Refresh',
            () => context.read<RfidScanBloc>().refreshScanResults(),
            backgroundColor: Colors.orange,
          );
        }
      } catch (e) {
        debugPrint('Error fetching new asset: $e');

        if (mounted) {
          RfidNavigationService.showSnackBarWithAction(
            context,
            'สร้างสำเร็จแต่เกิดข้อผิดพลาดในการอัปเดตหน้าจอ: ${e.toString()}',
            'Refresh',
            () => context.read<RfidScanBloc>().refreshScanResults(),
            backgroundColor: Colors.orange,
          );
        }
      }
    }
  }
}
