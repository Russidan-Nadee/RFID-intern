import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/service/auth_service.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../../domain/repositories/asset_repository.dart';

class AssetCreationPreviewScreen extends StatefulWidget {
  final Asset asset;
  final VoidCallback? onCreatePressed;
  final bool isLoading;
  final AssetRepository assetRepository;

  const AssetCreationPreviewScreen({
    Key? key,
    required this.asset,
    this.onCreatePressed,
    this.isLoading = false,
    required this.assetRepository,
  }) : super(key: key);

  @override
  State<AssetCreationPreviewScreen> createState() =>
      _AssetCreationPreviewScreenState();
}

class _AssetCreationPreviewScreenState
    extends State<AssetCreationPreviewScreen> {
  bool _isCreating = false;
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('รายละเอียดสินทรัพย์'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงข้อความสำเร็จ (ถ้ามี)
                if (_isSuccess)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'สร้างสินทรัพย์สำเร็จ!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ส่วนหัวแสดงรหัสและหมวดหมู่
                _buildHeaderCard(context),

                const SizedBox(height: 24),

                // ส่วนแสดงสถานะปัจจุบัน
                _buildStatusCard(context),

                const SizedBox(height: 24),

                // ส่วนแสดงข้อมูลทั้งหมด
                _buildAllDataCard(context),

                const SizedBox(height: 24),

                // แสดงข้อความผิดพลาด (ถ้ามี)
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // ปุ่มกลับ (ด้านซ้าย)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isCreating
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                  },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.purple,
                          ),
                          label: const Text(
                            'กลับ',
                            style: TextStyle(color: Colors.purple),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          if (!authService.canCreateAssets) {
                            return const SizedBox.shrink(); // ซ่อนปุ่มสำหรับ Viewer
                          }

                          return Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  (_isCreating || _isSuccess)
                                      ? null
                                      : () async {
                                        setState(() {
                                          _isCreating = true;
                                          _errorMessage = null;
                                        });

                                        try {
                                          final success = await widget
                                              .assetRepository
                                              .createAsset(widget.asset);

                                          if (!mounted) return;

                                          if (success) {
                                            setState(() {
                                              _isCreating = false;
                                              _isSuccess = true;
                                            });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'สร้างสินทรัพย์สำเร็จ',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            // รอสักครู่ก่อนกลับไปหน้าก่อนหน้า
                                            Future.delayed(
                                              const Duration(seconds: 2),
                                              () {
                                                if (mounted) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(true);
                                                }
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              _isCreating = false;
                                              _errorMessage =
                                                  'ไม่สามารถสร้างสินทรัพย์ได้';
                                            });

                                            // เพิ่ม dialog แสดงข้อผิดพลาด
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'ไม่สามารถสร้างสินทรัพย์ได้',
                                                    ),
                                                    content: const Text(
                                                      'อาจเป็นเพราะ EPC นี้มีในระบบแล้ว หรือการเชื่อมต่อมีปัญหา',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'ตกลง',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        } catch (e) {
                                          setState(() {
                                            _isCreating = false;
                                            _errorMessage = e.toString();
                                          });

                                          // เพิ่ม dialog แสดงข้อผิดพลาดจาก exception
                                          showDialog(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'เกิดข้อผิดพลาด',
                                                  ),
                                                  content: Text(
                                                    'รายละเอียด: ${e.toString()}',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                          ),
                                                      child: const Text('ตกลง'),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        }
                                      },
                              icon:
                                  _isCreating
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : _isSuccess
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                      : const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                      ),
                              label: Text(
                                _isCreating
                                    ? 'กำลังสร้าง...'
                                    : _isSuccess
                                    ? 'สำเร็จแล้ว'
                                    : 'Create Asset',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isSuccess
                                        ? Colors.green.shade700
                                        : Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Overlay ตอนกำลังโหลด
          if (_isCreating)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(51),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                        SizedBox(height: 24),
                        Text(
                          'กำลังสร้างสินทรัพย์...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ส่วนหัวแสดงรหัสและหมวดหมู่
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(widget.asset.category),
              size: 24,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${widget.asset.id}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.asset.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.asset.itemName,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนแสดงสถานะ
  Widget _buildStatusCard(BuildContext context) {
    final Color statusColor = _getStatusColor(widget.asset.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถานะปัจจุบัน',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.asset.status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ตำแหน่ง: ${widget.asset.currentLocation}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'อัปเดตล่าสุด: ${widget.asset.lastScanTime}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ส่วนแสดงข้อมูลทั้งหมด
  Widget _buildAllDataCard(BuildContext context) {
    // สร้างรายการข้อมูลที่ต้องการแสดง
    final dataMap = {
      'batchNumber': widget.asset.batchNumber,
      'batteryLevel': widget.asset.batteryLevel,
      'category': widget.asset.category,
      'currentLocation': widget.asset.currentLocation,
      'epc': widget.asset.epc,
      'frequency': widget.asset.frequency,
      'id': widget.asset.id,
      'itemId': widget.asset.itemId,
      'itemName': widget.asset.itemName,
      'lastScanTime': widget.asset.lastScanTime,
      'lastScannedBy': widget.asset.lastScannedBy,
      'status': widget.asset.status,
      'tagId': widget.asset.tagId,
      'tagType': widget.asset.tagType,
      'value': widget.asset.value,
      'zone': widget.asset.zone,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'ข้อมูลทั้งหมด',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),

          // แสดงรายการข้อมูลทั้งหมด
          ...dataMap.entries
              .map((entry) => _buildDataRow(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  // สร้างแถวข้อมูลแต่ละรายการ
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับกำหนดไอคอนตามหมวดหมู่
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'equipment':
        return Icons.handyman;
      case 'finished good':
        return Icons.inventory_2;
      case 'raw material':
        return Icons.category;
      case 'tool':
        return Icons.build;
      default:
        return Icons.devices_other;
    }
  }

  // ฟังก์ชันสำหรับกำหนดสีตามสถานะ
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in stock':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'in transit':
        return Colors.orange;
      case 'returned':
        return Colors.purple;
      case 'damaged':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
