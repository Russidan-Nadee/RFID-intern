/* Path: lib/presentation/features/assets/screens/asset_creation_preview_screen.dart */
import 'package:flutter/material.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import '../../../common_widgets/layouts/screen_container.dart';

class AssetCreationPreviewScreen extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onCreatePressed;
  final bool isLoading;

  const AssetCreationPreviewScreen({
    Key? key,
    required this.asset,
    this.onCreatePressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('รายละเอียดสินทรัพย์'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, // ซ่อนปุ่มกลับบน AppBar
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัวแสดงรหัสและหมวดหมู่
            _buildHeaderCard(context),

            const SizedBox(height: 24),

            // ส่วนแสดงสถานะปัจจุบัน
            _buildStatusCard(context),

            const SizedBox(height: 24),

            // ส่วนแสดงข้อมูลทั้งหมด
            _buildAllDataCard(context),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // ปุ่มกลับ (ด้านซ้าย)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.purple),
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

                  // ปุ่ม Create Asset (ด้านขวา) - เปลี่ยนกลับเป็น Create Asset
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          onCreatePressed ??
                          () {
                            print(
                              'Create Asset button pressed - no action implemented yet',
                            );
                          },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Create Asset',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
              _getCategoryIcon(asset.category),
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
                      '#${asset.id}',
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
                        asset.category,
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
                Text(asset.itemName, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนแสดงสถานะ
  Widget _buildStatusCard(BuildContext context) {
    final Color statusColor = _getStatusColor(asset.status);

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
                      asset.status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ตำแหน่ง: ${asset.currentLocation}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'อัปเดตล่าสุด: ${asset.lastScanTime}',
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
      'batchNumber': asset.batchNumber,
      'batteryLevel': asset.batteryLevel,
      'category': asset.category,
      'currentLocation': asset.currentLocation,
      'epc': asset.epc,
      'frequency': asset.frequency,
      'id': asset.id,
      'itemId': asset.itemId,
      'itemName': asset.itemName,
      'lastScanTime': asset.lastScanTime,
      'lastScannedBy': asset.lastScannedBy,
      'status': asset.status,
      'tagId': asset.tagId,
      'tagType': asset.tagType,
      'value': asset.value,
      'zone': asset.zone,
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
