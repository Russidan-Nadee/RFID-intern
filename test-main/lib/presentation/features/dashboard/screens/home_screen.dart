import 'package:flutter/material.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/utils/icon_utils.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Asset> _assets = [];
  String _errorMessage = '';

  final AssetRepository _assetRepository =
      DependencyInjection.get<AssetRepository>();

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final assets = await _assetRepository.getAssets();
      setState(() {
        _assets = assets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดโทนสีหลัก
    final primaryColor = Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;
    final cardColor = Color(0xFFF5F5F8); // สีเทาอ่อนสำหรับการ์ด
    final lightPrimaryColor = Color(0xFFE6E4F4); // สีม่วงอ่อนแทน withOpacity

    return ScreenContainer(
      backgroundColor: backgroundColor,
      statusBarColor: Color(0xFFE0E0E0), // สีเทาสำหรับ StatusBar
      appBar: AppBar(
        title: Text(
          'Asset Management Dashboard',
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.settings);
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
              : _errorMessage.isNotEmpty
              ? _buildErrorView(primaryColor)
              : _buildHomeContent(primaryColor, cardColor, lightPrimaryColor),
    );
  }

  // แสดงข้อผิดพลาด
  Widget _buildErrorView(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('เกิดข้อผิดพลาด: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAssets,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองใหม่'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
        ],
      ),
    );
  }

  // แสดงเนื้อหาหน้า Home
  Widget _buildHomeContent(
    Color primaryColor,
    Color cardColor,
    Color lightPrimaryColor,
  ) {
    // เรียงลำดับสินทรัพย์ตามวันที่สแกนล่าสุด
    final latestAssets = List<Asset>.from(_assets);
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
      color: primaryColor,
      onRefresh: () async {
        await _loadAssets();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงจำนวนสินทรัพย์ทั้งหมด
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: lightPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สินทรัพย์ทั้งหมด',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        '${_assets.length} รายการ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // หัวข้อการแจ้งเตือนล่าสุด
            Row(
              children: [
                Icon(Icons.notifications, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'การแจ้งเตือนล่าสุด',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // รายการการแจ้งเตือน
            latestFiveAssets.isEmpty
                ? Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 16),
                      Text('ไม่มีการแจ้งเตือนล่าสุด'),
                    ],
                  ),
                )
                : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestFiveAssets.length,
                  itemBuilder: (context, index) {
                    final asset = latestFiveAssets[index];

                    // กำหนดสีตามสถานะโดยไม่ใช้ withOpacity
                    Color statusColor = primaryColor;
                    Color bgStatusColor = lightPrimaryColor;

                    if (asset.status.toLowerCase() == 'checked in') {
                      statusColor = Colors.green;
                      bgStatusColor = Color(0xFFE6F4E6); // สีเขียวอ่อน
                    } else if (asset.status.toLowerCase() == 'in use') {
                      statusColor = Colors.orange;
                      bgStatusColor = Color(0xFFF9F0E6); // สีส้มอ่อน
                    } else if (asset.status.toLowerCase() == 'maintenance') {
                      statusColor = Colors.red;
                      bgStatusColor = Color(0xFFF9E6E6); // สีแดงอ่อน
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstants.assetDetail,
                            arguments: {'guid': asset.uid},
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: bgStatusColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    getStatusIcon(asset.status),
                                    color: statusColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.id,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${asset.category} - ${asset.status}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDate(asset.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

            // เพิ่มส่วนดูทรัพย์สินทั้งหมดที่ด้านล่าง
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _onItemTapped(1); // 1 คือ index ของหน้า Search
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'ดูทรัพย์สินทั้งหมด',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // เพิ่มพื้นที่ว่างด้านล่าง
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
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
