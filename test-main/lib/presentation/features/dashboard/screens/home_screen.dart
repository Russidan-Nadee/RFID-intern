import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../core/di/dependency_injection.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<List<Asset>> _assetsFuture;
  final AssetRepository _assetRepository =
      DependencyInjection.get<AssetRepository>();

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  void _loadAssets() {
    _assetsFuture = _assetRepository.getAssets();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('Asset Management Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouteConstants.settings);
            },
            tooltip: 'การตั้งค่า',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadAssets();
              });
            },
            tooltip: 'รีเฟรชข้อมูล',
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: FutureBuilder<List<Asset>>(
        future: _assetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _loadAssets();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final assets = snapshot.data ?? [];

          // เรียงลำดับสินทรัพย์ตามวันที่สแกนล่าสุด
          final latestAssets = List<Asset>.from(assets);
          latestAssets.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.date);
              final dateB = DateTime.parse(b.date);
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });

          // จำกัดแค่ 5 รายการแรก
          final latestFiveAssets = latestAssets.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadAssets();
              });
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // แสดงจำนวนสินทรัพย์ทั้งหมด
                  _buildTotalAssetCard(assets.length),

                  const SizedBox(height: 24),

                  // แสดงรายการที่สแกนล่าสุด 5 รายการในรูปแบบการแจ้งเตือน
                  _buildLatestScannedAssetsSection(latestFiveAssets),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalAssetCard(int totalAssets) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            const Icon(Icons.inventory_2, size: 48, color: Colors.blue),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สินทรัพย์ทั้งหมด',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '$totalAssets รายการ',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestScannedAssetsSection(List<Asset> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications, color: Colors.orange.shade800),
            const SizedBox(width: 8),
            const Text(
              'การแจ้งเตือนล่าสุด',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (assets.isEmpty)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 16),
                  Text('ไม่มีการแจ้งเตือนล่าสุด'),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];

              // กำหนดสีและไอคอนตามสถานะ
              Color cardColor = Colors.white;
              IconData statusIcon = Icons.info_outline;
              Color iconColor = Colors.blue;

              if (asset.status == 'Checked In') {
                cardColor = Colors.green.shade50;
                statusIcon = Icons.check_circle_outline;
                iconColor = Colors.green;
              } else if (asset.status == 'Available') {
                cardColor = Colors.blue.shade50;
                statusIcon = Icons.inventory_2;
                iconColor = Colors.blue;
              } else if (asset.status == 'In Use') {
                cardColor = Colors.orange.shade50;
                statusIcon = Icons.people_outline;
                iconColor = Colors.orange;
              } else if (asset.status == 'Maintenance') {
                cardColor = Colors.red.shade50;
                statusIcon = Icons.build_outlined;
                iconColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                color: cardColor,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteConstants.assetDetail,
                      arguments: {'guid': asset.uid},
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: iconColor.withAlpha(51),
                          child: Icon(statusIcon, color: iconColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      asset.brand,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: iconColor.withAlpha(50),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      asset.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${asset.id} • ${_getActivityMessage(asset)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTimeForNotification(asset.date),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        if (assets.isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('ดูสินทรัพย์ทั้งหมด'),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteConstants.searchAssets,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getActivityMessage(Asset asset) {
    switch (asset.status) {
      case 'Checked In':
        return 'ตรวจรับเข้าแล้ว';
      case 'Available':
        return 'พร้อมใช้งาน';
      case 'In Use':
        return 'กำลังใช้งาน';
      case 'Maintenance':
        return 'อยู่ในการซ่อมบำรุง';
      default:
        return 'สถานะ: ${asset.status}';
    }
  }

  String _formatDateTimeForNotification(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} วันที่ผ่านมา';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ชั่วโมงที่ผ่านมา';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} นาทีที่ผ่านมา';
      } else {
        return 'เมื่อสักครู่';
      }
    } catch (e) {
      return dateString;
    }
  }
}
