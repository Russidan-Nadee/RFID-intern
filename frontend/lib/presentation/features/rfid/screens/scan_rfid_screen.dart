// เพิ่ม import สำหรับ navigation
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/domain/usecases/assets/generate_mock_asset_usecase.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/app_bottom_navigation.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/screen_container.dart';
import 'package:rfid_project/presentation/features/rfid/screens/asset_creation_preview_screen.dart';
import '../blocs/rfid_scan_bloc.dart';

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
  int _selectedIndex = 2; // RFID Scan tab

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
                    bloc.status == RfidScanStatus.scanning ||
                            bloc.status == RfidScanStatus.bulkUpdating
                        ? null
                        : () => _performRefreshScan(context, bloc),
                icon: Icon(
                  Icons.refresh,
                  color:
                      bloc.status == RfidScanStatus.scanning ||
                              bloc.status == RfidScanStatus.bulkUpdating
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
              return _buildInitialView(bloc, context);
            case RfidScanStatus.scanning:
              return _buildScanningView();
            case RfidScanStatus.scanned:
              return _buildScannedResultView(bloc, context);
            case RfidScanStatus.bulkUpdating:
              return _buildBulkUpdatingView();
            case RfidScanStatus.bulkUpdateComplete:
              return _buildBulkUpdateCompleteView(bloc);
            case RfidScanStatus.error:
              return _buildErrorView(bloc);
          }
        },
      ),
    );
  }

  // ... ส่วนที่เหลือของโค้ดเหมือนเดิม

  // =================== View Builders ===================
  // (คงเดิม - ไม่ต้องเปลี่ยน)

  Widget _buildInitialView(RfidScanBloc bloc, BuildContext context) {
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
            onPressed: () => bloc.performScan(context),
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

  Widget _buildScannedResultView(RfidScanBloc bloc, BuildContext context) {
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
                      return _buildResultCard(result, context);
                    },
                  )
                  : const Center(
                    child: Text(
                      'ไม่พบผลลัพธ์การสแกน',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
        ),
        // if (bloc.hasAvailableAssets)
        //   Container(
        //     width: double.infinity,
        //     padding: const EdgeInsets.all(16),
        //     child: ElevatedButton(
        //       onPressed: () => _showBulkCheckScreen(context, bloc),
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.deepPurple.shade400,
        //         foregroundColor: Colors.white,
        //         padding: const EdgeInsets.symmetric(vertical: 16),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //       ),
        //       child: const Text(
        //         'Bulk Check',
        //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildBulkUpdatingView() {
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
            'กำลัง Check Items...',
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

  Widget _buildBulkUpdateCompleteView(RfidScanBloc bloc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.check_circle,
              size: 50,
              color: Colors.deepPurple.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Check Items สำเร็จ!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 16),
          if (bloc.bulkUpdateResult != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Text(
                bloc.bulkUpdateResult!.summaryMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ),
        ],
      ),
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
            onPressed: () => bloc.performScan(context),
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

  // =================== Card Builders ===================

  Widget _buildResultCard(EpcScanResult result, BuildContext context) {
    if (result.asset != null) {
      return _buildAssetInfoCard(result.asset!, context);
    } else {
      return _buildUnknownEpcCard(result.epc!, context);
    }
  }

  Widget _buildAssetInfoCard(Asset asset, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToAssetDetail(asset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.deepPurple.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.itemName ?? 'ไม่ระบุชื่อ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${asset.status}',
                      style: TextStyle(
                        color: _getStatusColor(asset.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownEpcCard(String epc, BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAssetPreview(context, epc),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.red.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unknown Item',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: Unknown',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EPC: ${epc.length > 20 ? '${epc.substring(0, 20)}...' : epc}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // =================== Navigation Methods ===================

  void _navigateToAssetDetail(Asset asset) async {
    final result = await Navigator.pushNamed(
      context,
      '/assetDetail',
      arguments: {'tagId': asset.tagId},
    );

    if (result != null && result is Map && result['updated'] == true) {
      context.read<RfidScanBloc>().updateCardStatus(
        result['tagId'],
        result['newStatus'],
      );
    }
  }

  // Path: lib/presentation/features/rfid/screens/scan_rfid_screen.dart

  void _showAssetPreview(BuildContext context, String epc) async {
    try {
      // สร้าง preview asset จาก mock data
      final previewAsset = await widget.generateAssetUseCase.generatePreview(
        epc,
      );

      if (!mounted) return;

      // เปิดหน้า Asset Creation Preview และรอผลลัพธ์
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (context) => AssetCreationPreviewScreen(
                asset: previewAsset,
                assetRepository: widget.assetRepository,
              ),
        ),
      );

      // ถ้า create สำเร็จ (result == true)
      if (result == true) {
        // รอสักครู่ให้ API บันทึกข้อมูลเสร็จสิ้น
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          // ดึงข้อมูล Asset ใหม่ที่เพิ่งสร้างจาก API
          final newAsset = await widget.assetRepository.findAssetByEpc(epc);

          // ถ้าพบ Asset ใหม่และ widget ยังคง mounted
          if (newAsset != null && mounted) {
            // อัปเดต UI โดยเปลี่ยน Unknown EPC Card เป็น Asset Card
            context.read<RfidScanBloc>().updateUnknownEpcToAsset(epc, newAsset);

            // แสดงข้อความสำเร็จ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('สร้าง ${newAsset.itemName} สำเร็จ'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (mounted) {
            // กรณีที่ไม่พบ Asset ใหม่หลังจาก create
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'สร้างสำเร็จแต่ไม่สามารถอัปเดตหน้าจอได้ กรุณา refresh',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          // Error ในการดึงข้อมูล Asset ใหม่
          print('Error fetching new asset: $e');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'สร้างสำเร็จแต่เกิดข้อผิดพลาดในการอัปเดตหน้าจอ: ${e.toString()}',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Refresh',
                  onPressed:
                      () => context.read<RfidScanBloc>().performScan(context),
                ),
              ),
            );
          }
        }
      }
      // ถ้า result == false หรือ null หมายความว่า user กดยกเลิกหรือ create ไม่สำเร็จ
      // ไม่ต้องทำอะไร Unknown Card จะยังคงเป็นสีแดงอยู่
    } catch (e) {
      // Error ในการสร้าง preview asset
      print('Error in asset preview: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเตรียมข้อมูล: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  // =================== Bulk Check Methods ===================

  void _showBulkCheckScreen(BuildContext context, RfidScanBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _BulkCheckScreen(
            availableAssets: bloc.availableAssets,
            onConfirm:
                (selectedTagIds) =>
                    _confirmBulkCheck(context, bloc, selectedTagIds),
          ),
    );
  }

  void _confirmBulkCheck(
    BuildContext context,
    RfidScanBloc bloc,
    List<String> selectedTagIds,
  ) {
    if (selectedTagIds.isEmpty) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ยืนยันการ Check Items'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('จะเปลี่ยนสถานะ ${selectedTagIds.length} รายการ:'),
                const SizedBox(height: 8),
                ...selectedTagIds.take(3).map((tagId) {
                  final asset = bloc.availableAssets.firstWhere(
                    (a) => a.tagId == tagId,
                  );
                  return Text('• ${asset.itemName}');
                }),
                if (selectedTagIds.length > 3)
                  Text('และอีก ${selectedTagIds.length - 3} รายการ'),
                const SizedBox(height: 8),
                const Text('จาก Available → Checked'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  bloc.bulkUpdateSelectedAssets(selectedTagIds);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade400,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ยืนยัน'),
              ),
            ],
          ),
    );
  }

  // =================== Helper Methods ===================

  void _performRefreshScan(BuildContext context, RfidScanBloc bloc) {
    bloc.performScan(context);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.deepPurple;
      case 'checked':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// =================== Bulk Check Screen ===================
// (คงเดิม - ไม่ต้องเปลี่ยน)

// Path: lib/presentation/features/rfid/screens/scan_rfid_screen.dart

class _BulkCheckScreen extends StatefulWidget {
  final List<Asset> availableAssets;
  final Function(List<String>) onConfirm;

  const _BulkCheckScreen({
    required this.availableAssets,
    required this.onConfirm,
  });

  @override
  State<_BulkCheckScreen> createState() => _BulkCheckScreenState();
}

class _BulkCheckScreenState extends State<_BulkCheckScreen> {
  final Set<String> _selectedTagIds = {};

  @override
  void initState() {
    super.initState();
    // Auto-select ทุก Available Items ตอนเริ่มต้น
    _selectedTagIds.addAll(widget.availableAssets.map((asset) => asset.tagId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Title และ Close button
                Row(
                  children: [
                    const Text(
                      'เลือก Available Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Control Buttons และ Counter
                Row(
                  children: [
                    // Select All Button
                    OutlinedButton.icon(
                      onPressed: _isAllSelected ? null : _selectAll,
                      icon: Icon(
                        Icons.check_box,
                        size: 18,
                        color: _isAllSelected ? Colors.grey : Colors.deepPurple,
                      ),
                      label: Text(
                        'Select All',
                        style: TextStyle(
                          color:
                              _isAllSelected ? Colors.grey : Colors.deepPurple,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              _isAllSelected
                                  ? Colors.grey.shade300
                                  : Colors.deepPurple,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Unselect All Button
                    OutlinedButton.icon(
                      onPressed: _isNoneSelected ? null : _unselectAll,
                      icon: Icon(
                        Icons.check_box_outline_blank,
                        size: 18,
                        color:
                            _isNoneSelected ? Colors.grey : Colors.red.shade600,
                      ),
                      label: Text(
                        'Unselect All',
                        style: TextStyle(
                          color:
                              _isNoneSelected
                                  ? Colors.grey
                                  : Colors.red.shade600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color:
                              _isNoneSelected
                                  ? Colors.grey.shade300
                                  : Colors.red.shade600,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Text(
                        '${_selectedTagIds.length}/${widget.availableAssets.length} Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.availableAssets.length,
              itemBuilder: (context, index) {
                final asset = widget.availableAssets[index];
                final isSelected = _selectedTagIds.contains(asset.tagId);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isSelected ? 2 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color:
                          isSelected
                              ? Colors.deepPurple.shade200
                              : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTagIds.add(asset.tagId);
                        } else {
                          _selectedTagIds.remove(asset.tagId);
                        }
                      });
                    },
                    title: Text(
                      asset.itemName ?? 'ไม่ระบุชื่อ',
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('Tag ID: ${asset.tagId}'),
                    secondary: Icon(
                      Icons.inventory_2,
                      color: Colors.deepPurple.shade400,
                    ),
                    activeColor: Colors.deepPurple,
                    checkColor: Colors.white,
                  ),
                );
              },
            ),
          ),

          // Footer Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),

                const SizedBox(width: 16),

                // Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _selectedTagIds.isNotEmpty
                            ? () => widget.onConfirm(_selectedTagIds.toList())
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _selectedTagIds.isNotEmpty
                          ? 'Check Items (${_selectedTagIds.length})'
                          : 'Check Items',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================== Helper Methods ===================

  /// เลือกทุก Available Items
  void _selectAll() {
    setState(() {
      _selectedTagIds.clear();
      _selectedTagIds.addAll(
        widget.availableAssets.map((asset) => asset.tagId),
      );
    });
  }

  /// ยกเลิกการเลือกทั้งหมด
  void _unselectAll() {
    setState(() {
      _selectedTagIds.clear();
    });
  }

  /// ตรวจสอบว่าเลือกครบทุกตัวหรือไม่
  bool get _isAllSelected {
    return _selectedTagIds.length == widget.availableAssets.length;
  }

  /// ตรวจสอบว่าไม่ได้เลือกเลยหรือไม่
  bool get _isNoneSelected {
    return _selectedTagIds.isEmpty;
  }
}
