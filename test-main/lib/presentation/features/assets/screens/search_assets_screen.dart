// lib/presentation/features/assets/screens/search_assets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/asset_bloc.dart';
import '../widgets/asset_table_view.dart';

class SearchAssetsScreen extends StatefulWidget {
  const SearchAssetsScreen({Key? key}) : super(key: key);

  @override
  State<SearchAssetsScreen> createState() => _SearchAssetsScreenState();
}

class _SearchAssetsScreenState extends State<SearchAssetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1; // Index for the Search tab
  final GlobalKey _statusColumnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssetBloc>(context, listen: false).loadAssets();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ใช้โทนสีใหม่
    final primaryColor = Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;
    final cardColor = Color(0xFFF5F5F8); // สีเทาอ่อนสำหรับการ์ด

    return ScreenContainer(
      backgroundColor: backgroundColor,
      statusBarColor: Color(0xFFE0E0E0), // สีเทาสำหรับ StatusBar
      appBar: AppBar(
        title: Text(
          'Asset Search',
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // เพิ่มปุ่ม Export
          Consumer<AssetBloc>(
            builder:
                (context, bloc, _) => IconButton(
                  icon: Icon(Icons.file_download, color: primaryColor),
                  onPressed: () {
                    // ส่งข้อมูลการค้นหาไปยังหน้า Export
                    Navigator.pushNamed(
                      context,
                      '/export',
                      arguments: {
                        'searchParams': {
                          'status': bloc.selectedStatus,
                          'query': _searchController.text,
                        },
                      },
                    );
                  },
                  tooltip: 'Export Search Results',
                ),
          ),
          // ปุ่มสลับโหมดการแสดง
          Consumer<AssetBloc>(
            builder:
                (context, bloc, _) => IconButton(
                  icon: Icon(
                    bloc.isTableView ? Icons.view_list : Icons.grid_view,
                    color: primaryColor,
                  ),
                  onPressed: () {
                    bloc.toggleViewMode();
                  },
                  tooltip: bloc.isTableView ? 'Card View' : 'Table View',
                ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Column(
        children: [
          // ส่วนค้นหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // ช่องค้นหา
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        context.read<AssetBloc>().setSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search for assets...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  // แสดงจำนวนที่พบ
                  Consumer<AssetBloc>(
                    builder: (context, bloc, _) {
                      if (bloc.status == AssetStatus.loading) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Found ${bloc.filteredAssets.length} assets',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // รายการผลลัพธ์
          Expanded(
            child: Consumer<AssetBloc>(
              builder: (context, bloc, _) {
                if (bloc.status == AssetStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                } else if (bloc.status == AssetStatus.error) {
                  return _buildErrorView(bloc.errorMessage);
                } else if (bloc.filteredAssets.isEmpty) {
                  return _buildEmptyResults();
                } else {
                  // เลือกแสดงผลตามโหมดที่เลือก
                  return bloc.isTableView
                      ? AssetTableView(
                        assets: bloc.filteredAssets,
                        statusColumnKey: _statusColumnKey,
                        bloc: bloc,
                      )
                      : _buildResultsList(bloc, cardColor, primaryColor);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // แสดงข้อผิดพลาด
  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error loading assets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // แสดงเมื่อไม่พบผลลัพธ์
  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No assets found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try using different search terms',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // แสดงรายการผลลัพธ์แบบการ์ด
  Widget _buildResultsList(
    AssetBloc bloc,
    Color cardColor,
    Color primaryColor,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: bloc.filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = bloc.filteredAssets[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.inventory, color: primaryColor, size: 20),
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  asset.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Status: ${asset.status}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Export button for each asset
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.green),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/export',
                      arguments: {
                        'assetId': asset.id,
                        'assetUid': asset.uid,
                        'scrollTobottom': true,
                      },
                    );
                  },
                  tooltip: 'Export this asset',
                ),
                Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/assetDetail',
                arguments: {'guid': asset.uid},
              );
            },
          ),
        );
      },
    );
  }
}
