// lib/presentation/features/assets/screens/search_assets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/status/loading_error_widget.dart';
import '../../../common_widgets/status/empty_results_widget.dart';
import '../../../common_widgets/inputs/search_box_widget.dart';
import '../blocs/asset_bloc.dart';
import '../widgets/asset_table_view.dart';
import '../widgets/search_result_list.dart';

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
    final primaryColor = const Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;
    final cardColor = const Color(0xFFF5F5F8); // สีเทาอ่อนสำหรับการ์ด

    return ScreenContainer(
      backgroundColor: backgroundColor,
      statusBarColor: const Color(0xFFE0E0E0), // สีเทาสำหรับ StatusBar
      appBar: AppBar(
        title: Text(
          'Asset Search',
          style: TextStyle(
            color: primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: _buildAppBarActions(primaryColor),
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
            child: _buildSearchBox(primaryColor, cardColor),
          ),

          // รายการผลลัพธ์
          Expanded(child: _buildSearchResults(primaryColor, cardColor)),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(Color primaryColor) {
    return [
      Consumer<AssetBloc>(
        builder:
            (context, bloc, _) => IconButton(
              icon: Icon(
                bloc.isTableView ? Icons.view_list : Icons.grid_view,
                color: primaryColor,
              ),
              onPressed: () => bloc.toggleViewMode(),
              tooltip: bloc.isTableView ? 'Card View' : 'Table View',
            ),
      ),
    ];
  }

  // สร้างกล่องค้นหา
  Widget _buildSearchBox(Color primaryColor, Color cardColor) {
    return Consumer<AssetBloc>(
      builder: (context, bloc, _) {
        return SearchBoxWidget(
          controller: _searchController,
          onChanged: (value) => bloc.setSearchQuery(value),
          cardColor: cardColor,
          primaryColor: primaryColor,
          showResultCount: true,
          resultCount: bloc.filteredAssets.length,
          isLoading: bloc.status == AssetStatus.loading,
        );
      },
    );
  }

  // สร้างรายการผลลัพธ์
  Widget _buildSearchResults(Color primaryColor, Color cardColor) {
    return Consumer<AssetBloc>(
      builder: (context, bloc, _) {
        if (bloc.status == AssetStatus.loading) {
          return LoadingWidget(primaryColor: primaryColor);
        } else if (bloc.status == AssetStatus.error) {
          return ErrorDisplayWidget(
            errorMessage: bloc.errorMessage,
            onRetry: () => bloc.loadAssets(),
            primaryColor: primaryColor,
          );
        } else if (bloc.filteredAssets.isEmpty) {
          return const EmptyResultsWidget();
        } else {
          // เลือกแสดงผลตามโหมดที่เลือก
          return bloc.isTableView
              ? AssetTableView(
                assets: bloc.filteredAssets,
                statusColumnKey: _statusColumnKey,
                bloc: bloc,
              )
              : SearchResultList(
                assets: bloc.filteredAssets,
                cardColor: cardColor,
                primaryColor: primaryColor,
                onAssetSelected:
                    (asset) => bloc.navigateToAssetDetail(context, asset),
                onExportAsset:
                    (asset) => bloc.navigateToExport(
                      context,
                      asset,
                      scrollToBottom: true,
                    ),
              );
        }
      },
    );
  }
}
