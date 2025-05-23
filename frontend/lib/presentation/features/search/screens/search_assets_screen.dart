import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/presentation/features/search/widgets/search_box_widget.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/status/loading_error_widget.dart';
import '../../../common_widgets/status/empty_results_widget.dart';
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
          // =================== Search Section ===================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Box
                _buildSearchBox(primaryColor, cardColor),

                // Multi-Select Action Chips
                _buildMultiSelectChips(primaryColor),
              ],
            ),
          ),

          // =================== Results Section ===================
          Expanded(child: _buildSearchResults(primaryColor, cardColor)),
        ],
      ),
    );
  }

  // =================== AppBar Actions ===================
  List<Widget> _buildAppBarActions(Color primaryColor) {
    return [
      Consumer<AssetBloc>(
        builder: (context, bloc, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Multi-Select Toggle Button
              IconButton(
                icon: Icon(
                  bloc.isMultiSelectMode ? Icons.close : Icons.checklist_rtl,
                  color: primaryColor,
                ),
                onPressed: () => bloc.toggleMultiSelectMode(),
                tooltip:
                    bloc.isMultiSelectMode ? 'ยกเลิกเลือก' : 'เลือกหลายรายการ',
              ),

              // View Mode Toggle Button
              IconButton(
                icon: Icon(
                  bloc.isTableView ? Icons.view_list : Icons.grid_view,
                  color: primaryColor,
                ),
                onPressed: () => bloc.toggleViewMode(),
                tooltip: bloc.isTableView ? 'Card View' : 'Table View',
              ),
            ],
          );
        },
      ),
    ];
  }

  // =================== Search Box ===================
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

          // =================== Multi-Select Parameters ===================
          isMultiSelectMode: bloc.isMultiSelectMode,
          selectedCount: bloc.selectedCount,
        );
      },
    );
  }

  // =================== Multi-Select Action Chips ===================
  Widget _buildMultiSelectChips(Color primaryColor) {
    return Consumer<AssetBloc>(
      builder: (context, bloc, _) {
        if (!bloc.isMultiSelectMode) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Export Chip
                _buildActionChip(
                  icon: Icons.file_download,
                  label: 'Export ${bloc.selectedCount} items',
                  color: primaryColor,
                  onPressed: () => bloc.navigateToMultiExport(context),
                ),

                const SizedBox(width: 8),

                // Select All Chip
                _buildActionChip(
                  icon: Icons.select_all,
                  label: 'Select All',
                  color: Colors.blue,
                  onPressed: () => bloc.selectAllAssets(),
                ),

                const SizedBox(width: 8),

                // Clear Selection Chip
                _buildActionChip(
                  icon: Icons.clear,
                  label: 'Clear',
                  color: Colors.grey,
                  onPressed: () => bloc.clearSelection(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      onPressed: onPressed,
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.1),
    );
  }

  // =================== Search Results ===================
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

                // =================== Multi-Select Parameters ===================
                isMultiSelectMode: bloc.isMultiSelectMode,
                selectedAssetIds: bloc.selectedAssetIds,
                onAssetSelectionChanged: (assetId, isSelected) {
                  bloc.toggleAssetSelection(assetId);
                },
                onSelectAll: () => bloc.selectAllAssets(),
                onClearSelection: () => bloc.clearSelection(),
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

                // =================== Multi-Select Parameters ===================
                isMultiSelectMode: bloc.isMultiSelectMode,
                selectedAssetIds: bloc.selectedAssetIds,
                onAssetSelectionChanged: (assetId, isSelected) {
                  bloc.toggleAssetSelection(assetId);
                },
              );
        }
      },
    );
  }
}
