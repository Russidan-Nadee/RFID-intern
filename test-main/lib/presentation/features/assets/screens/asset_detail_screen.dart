// lib/presentation/features/assets/screens/asset_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/buttons/primary_button.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({Key? key}) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  String? _guid;
  Map<String, dynamic>? _assetData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // รับค่า guid จาก arguments
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments.containsKey('guid')) {
      final newGuid = arguments['guid'] as String?;

      if (_guid != newGuid) {
        setState(() {
          _guid = newGuid;
          _isLoading = true;
          _errorMessage = null;
          _assetData = null;
        });

        // โหลดข้อมูลสินทรัพย์ดิบทั้งหมด
        _loadRawAssetDetails();
      }
    }
  }

  // โหลดข้อมูลดิบทั้งหมดของสินทรัพย์ผ่าน Repository
  Future<void> _loadRawAssetDetails() async {
    if (_guid == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = Provider.of<AssetRepository>(context, listen: false);
      final data = await repository.getRawAssetData(_guid!);

      setState(() {
        _assetData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('รายละเอียดสินทรัพย์'),
        centerTitle: true,
        elevation: 0,
      ),
      child:
          _guid == null
              ? _buildNoGuidMessage()
              : _isLoading
              ? _buildLoadingView()
              : _errorMessage != null
              ? _buildErrorView(_errorMessage!)
              : _assetData == null
              ? _buildAssetNotFoundView()
              : _buildAssetDetailsView(_assetData!),
    );
  }

  // สร้างหน้าแสดงข้อความว่าไม่มี GUID
  Widget _buildNoGuidMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบข้อมูล GUID',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'กรุณากลับไปเลือกสินทรัพย์ที่ต้องการดูรายละเอียด',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'กลับไปหน้าค้นหา',
            icon: Icons.search,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // สร้างหน้าแสดงข้อความว่ากำลังโหลด
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('กำลังโหลดข้อมูล...'),
        ],
      ),
    );
  }

  // สร้างหน้าแสดงข้อความว่าเกิดข้อผิดพลาด
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'เกิดข้อผิดพลาดในการโหลดข้อมูล',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'ลองอีกครั้ง',
            icon: Icons.refresh,
            onPressed: _loadRawAssetDetails,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('กลับ'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // สร้างหน้าแสดงข้อความว่าไม่พบสินทรัพย์
  Widget _buildAssetNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'ไม่พบข้อมูลสินทรัพย์',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ไม่พบข้อมูลสินทรัพย์สำหรับรหัส: $_guid',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'กลับไปหน้าค้นหา',
            icon: Icons.search,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // สร้างหน้าแสดงรายละเอียดสินทรัพย์จากข้อมูลดิบทั้งหมด
  Widget _buildAssetDetailsView(Map<String, dynamic> assetData) {
    // ดึงค่า status มาเพื่อใช้ในการกำหนดสี
    final status = assetData['status']?.toString() ?? 'Unknown';
    Color statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวแสดงรหัสและหมวดหมู่
          _buildHeaderCard(assetData),

          const SizedBox(height: 24),

          // ส่วนแสดงสถานะ
          _buildStatusCard(assetData, statusColor),

          const SizedBox(height: 24),

          // ส่วนแสดงข้อมูลทั้งหมดแบบตาราง
          _buildAllDataCard(assetData),

          const SizedBox(height: 24),

          // ปุ่มดำเนินการและกลับ
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'กลับ',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ส่วนหัวแสดงรหัสและหมวดหมู่
  Widget _buildHeaderCard(Map<String, dynamic> assetData) {
    final category = assetData['category']?.toString() ?? 'ไม่ระบุหมวดหมู่';
    final itemName = assetData['itemName']?.toString() ?? 'ไม่ระบุชื่อ';
    final id =
        assetData['id']?.toString() ??
        assetData['itemId']?.toString() ??
        'ไม่ระบุรหัส';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                _getCategoryIcon(category),
                size: 32,
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
                        '#$id',
                        style: TextStyle(
                          fontSize: 18,
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
                          category,
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
                    itemName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ส่วนแสดงสถานะ
  Widget _buildStatusCard(Map<String, dynamic> assetData, Color statusColor) {
    final status = assetData['status']?.toString() ?? 'Unknown';
    final location =
        assetData['currentLocation']?.toString() ?? 'ไม่ระบุตำแหน่ง';
    final lastScanTime = assetData['lastScanTime']?.toString() ?? 'ไม่ระบุเวลา';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'สถานะปัจจุบัน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),

            // แถวแสดงสถานะ
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(status),
                    color: statusColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ตำแหน่ง: $location',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        'อัปเดตล่าสุด: ${_formatDateTime(lastScanTime)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ส่วนแสดงข้อมูลทั้งหมดแบบตาราง
  Widget _buildAllDataCard(Map<String, dynamic> assetData) {
    // เรียงลำดับ key เพื่อดูง่าย
    final sortedKeys = assetData.keys.toList()..sort();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  'ข้อมูลทั้งหมด',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // แสดงทุกฟิลด์ในข้อมูล
            ...sortedKeys.map((key) {
              // หลีกเลี่ยงการแสดงข้อมูลที่เป็น null หรือว่างเปล่า
              final value = assetData[key]?.toString() ?? '';
              if (value.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันช่วยในการกำหนดไอคอนตามหมวดหมู่
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return Icons.laptop;
      case 'monitor':
        return Icons.desktop_windows;
      case 'mouse':
        return Icons.mouse;
      case 'keyboard':
        return Icons.keyboard;
      case 'printer':
        return Icons.print;
      case 'phone':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet_android;
      case 'camera':
        return Icons.camera_alt;
      case 'headphone':
        return Icons.headphones;
      case 'speaker':
        return Icons.speaker;
      case 'storage':
        return Icons.storage;
      case 'network':
        return Icons.router;
      case 'server':
        return Icons.dns;
      case 'tool':
        return Icons.build;
      case 'furniture':
        return Icons.chair;
      case 'vehicle':
        return Icons.directions_car;
      case 'raw material':
        return Icons.inventory_2;
      case 'finished good':
        return Icons.inventory;
      case 'equipment':
        return Icons.precision_manufacturing;
      case 'work in progress':
        return Icons.autorenew;
      default:
        return Icons.category;
    }
  }

  // ฟังก์ชันช่วยในการกำหนดไอคอนตามสถานะ
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle;
      case 'checked in':
        return Icons.login;
      case 'in use':
        return Icons.person;
      case 'maintenance':
        return Icons.build;
      case 'in production':
        return Icons.precision_manufacturing;
      case 'repair':
        return Icons.home_repair_service;
      case 'reserved':
        return Icons.bookmark;
      case 'disposed':
        return Icons.delete;
      case 'lost':
        return Icons.search_off;
      default:
        return Icons.info_outline;
    }
  }

  // ฟังก์ชันช่วยในการกำหนดสีตามสถานะ
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'checked in':
        return Colors.blue;
      case 'in use':
        return Colors.purple;
      case 'maintenance':
        return Colors.orange;
      case 'in production':
        return Colors.amber.shade800;
      case 'repair':
        return Colors.amber;
      case 'reserved':
        return Colors.teal;
      case 'disposed':
        return Colors.red.shade300;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ฟังก์ชันช่วยในการจัดรูปแบบวันที่
  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
