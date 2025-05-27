// Path: frontend/lib/presentation/features/search/screens/search_assets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rfid_project/presentation/features/search/widgets/search_box_widget.dart';
import 'package:rfid_project/core/navigation/search_navigation_service.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/status/loading_error_widget.dart';
import '../../../common_widgets/status/empty_results_widget.dart';
import '../blocs/asset_bloc.dart';
import '../blocs/asset_state.dart';
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
      context.read<AssetBloc>().loadAssets();
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
      child: BlocListener<AssetBloc, AssetState>(
        listener: (context, state) {
          // Handle navigation events
          if (state is NavigateToAssetDetail) {
            SearchNavigationService.navigateToAssetDetail(context, state.asset);
          } else if (state is NavigateToExport) {
            SearchNavigationService.navigateToExport(
              context,
              state.asset,
              scrollToBottom: state.scrollToBottom,
            );
          } else if (state is NavigateToMultiExport) {
            SearchNavigationService.navigateToMultiExport(
              context,
              state.selectedAssets,
            );
          } else if (state is ShowAssetErrorMessage) {
            SearchNavigationService.showError(context, state.errorMessage);
          } else if (state is ShowAssetSuccessMessage) {
            SearchNavigationService.showSuccess(context, state.message);
          }
        },
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
      ),
    );
  }

  // =================== AppBar Actions ===================
  List<Widget> _buildAppBarActions(Color primaryColor) {
    return [
      BlocBuilder<AssetBloc, AssetState>(
        builder: (context, state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Multi-Select Toggle Button
              IconButton(
                icon: Icon(
                  state.isMultiSelectMode ? Icons.close : Icons.checklist_rtl,
                  color: primaryColor,
                ),
                onPressed:
                    () => context.read<AssetBloc>().toggleMultiSelectMode(),
                tooltip:
                    state.isMultiSelectMode ? 'ยกเลิกเลือก' : 'เลือกหลายรายการ',
              ),

              // View Mode Toggle Button
              IconButton(
                icon: Icon(
                  state.isTableView ? Icons.view_list : Icons.grid_view,
                  color: primaryColor,
                ),
                onPressed: () => context.read<AssetBloc>().toggleViewMode(),
                tooltip: state.isTableView ? 'Card View' : 'Table View',
              ),
            ],
          );
        },
      ),
    ];
  }

  // =================== Search Box ===================
  Widget _buildSearchBox(Color primaryColor, Color cardColor) {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        return SearchBoxWidget(
          controller: _searchController,
          onChanged: (value) => context.read<AssetBloc>().setSearchQuery(value),
          cardColor: cardColor,
          primaryColor: primaryColor,
          showResultCount: true,
          resultCount: state.filteredAssets.length,
          isLoading: state is AssetLoading,

          // =================== Multi-Select Parameters ===================
          isMultiSelectMode: state.isMultiSelectMode,
          selectedCount: state.selectedCount,
        );
      },
    );
  }

  // =================== Multi-Select Action Chips ===================
  Widget _buildMultiSelectChips(Color primaryColor) {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (!state.isMultiSelectMode) {
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
                  label: 'Export ${state.selectedCount} items',
                  color: primaryColor,
                  onPressed:
                      () => context.read<AssetBloc>().navigateToMultiExport(),
                ),

                const SizedBox(width: 8),

                // Select All Chip
                _buildActionChip(
                  icon: Icons.select_all,
                  label: 'Select All',
                  color: Colors.blue,
                  onPressed: () => context.read<AssetBloc>().selectAllAssets(),
                ),

                const SizedBox(width: 8),

                // Clear Selection Chip
                _buildActionChip(
                  icon: Icons.clear,
                  label: 'Clear',
                  color: Colors.grey,
                  onPressed: () => context.read<AssetBloc>().clearSelection(),
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
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (state is AssetLoading) {
          return LoadingWidget(primaryColor: primaryColor);
        } else if (state is AssetError) {
          return ErrorDisplayWidget(
            errorMessage: state.errorMessage,
            onRetry: () => context.read<AssetBloc>().loadAssets(),
            primaryColor: primaryColor,
          );
        } else if (state.filteredAssets.isEmpty) {
          return const EmptyResultsWidget();
        } else {
          // เลือกแสดงผลตามโหมดที่เลือก
          return state.isTableView
              ? AssetTableView(
                assets: state.filteredAssets,
                statusColumnKey: _statusColumnKey,
                bloc: context.read<AssetBloc>(),

                // =================== Multi-Select Parameters ===================
                isMultiSelectMode: state.isMultiSelectMode,
                selectedAssetIds: state.selectedAssetIds,
                onAssetSelectionChanged: (assetId, isSelected) {
                  context.read<AssetBloc>().toggleAssetSelection(assetId);
                },
                onSelectAll: () => context.read<AssetBloc>().selectAllAssets(),
                onClearSelection:
                    () => context.read<AssetBloc>().clearSelection(),
              )
              : SearchResultList(
                assets: state.filteredAssets,
                cardColor: cardColor,
                primaryColor: primaryColor,
                onAssetSelected:
                    (asset) =>
                        context.read<AssetBloc>().navigateToAssetDetail(asset),
                onExportAsset:
                    (asset) => context.read<AssetBloc>().navigateToExport(
                      asset,
                      scrollToBottom: true,
                    ),

                // =================== Multi-Select Parameters ===================
                isMultiSelectMode: state.isMultiSelectMode,
                selectedAssetIds: state.selectedAssetIds,
                onAssetSelectionChanged: (assetId, isSelected) {
                  context.read<AssetBloc>().toggleAssetSelection(assetId);
                },
              );
        }
      },
    );
  }
}
