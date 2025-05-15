import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/core/navigation/navigation_service.dart';
import 'package:rfid_project/presentation/features/export/screens/export_confirmation_screen.dart';
import 'package:rfid_project/presentation/features/export/widgets/export_column_selector.dart';
import 'package:rfid_project/presentation/features/export/widgets/export_selected_assets.dart';
import 'package:rfid_project/presentation/features/main/blocs/navigation_bloc.dart';
import 'package:rfid_project/presentation/common_widgets/buttons/primary_button.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/app_bottom_navigation.dart';
import 'package:rfid_project/presentation/common_widgets/layouts/screen_container.dart';
import 'package:rfid_project/presentation/features/export/blocs/export_bloc.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _shouldScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final exportBloc = context.read<ExportBloc>();

      exportBloc.setArguments(args);

      if (args != null && args['fromSearch'] == true) {
        setState(() {
          _shouldScrollToBottom = true;
        });
      }

      if (_shouldScrollToBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 4) return; // ถ้าเป็นแท็บปัจจุบัน (Export) ไม่ต้องทำอะไร
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final navigationBloc = Provider.of<NavigationBloc>(context);
    final currentIndex = navigationBloc.currentIndex;

    return ScreenContainer(
      appBar: AppBar(
        title: const Text('Export Assets Data'),
        // *** เอา bottomNavigationBar ออกจาก AppBar ***
      ),
      bottomNavigationBar: AppBottomNavigation(
        // *** ย้ายมาเป็น property ของ ScreenContainer ***
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<ExportBloc>(
        // *** เนื้อหาหลักของหน้าจออยู่ใน child ของ ScreenContainer ***
        builder: (context, bloc, _) {
          if (bloc.status == ExportStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column Selection Section
                ExportColumnSelector(
                  columnGroups: bloc.columnGroups,
                  onToggleColumn: bloc.toggleColumnSelection,
                  onSelectAllInGroup: bloc.selectAllColumnsInGroup,
                  onDeselectAllInGroup: bloc.deselectAllColumnsInGroup,
                  onSelectAll: bloc.selectAllColumns,
                  onDeselectAll: bloc.deselectAllColumns,
                  isColumnSelected: bloc.isColumnSelected,
                  areAllInGroupSelected:
                      (group) => bloc.areAllColumnsInGroupSelected(group),
                ),

                const SizedBox(height: 24),

                // Selected Assets Section
                ExportSelectedAssets(
                  selectedAssets: bloc.selectedAssets,
                  onRemoveAsset: bloc.removeAsset,
                  onClearAll: bloc.clearSelectedAssets,
                  onAddMore: () => _navigateToSearchScreen(context),
                  onSelectAll: bloc.selectAllAssets,
                ),

                // Data Preview Section
                // if (bloc.selectedAssets.isNotEmpty &&
                //     bloc.selectedColumns.isNotEmpty)
                //   ExportPreviewTable(
                //     previewAssets: bloc.selectedAssets,
                //     selectedColumns: bloc.selectedColumns,
                //     totalSelectedAssets: bloc.selectedAssets.length,
                //     estimatedFileSize: bloc.estimatedFileSize,
                //     getAssetValueByColumnKey: bloc.getAssetValueByColumnKey,
                //   ),

                // Export Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: PrimaryButton(
                      text: 'Export CSV',
                      icon: Icons.file_download,
                      onPressed: () => _navigateToConfirmationScreen(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.pushNamed(context, '/searchAssets');
  }

  void _navigateToConfirmationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportConfirmationScreen()),
    );
  }
}
