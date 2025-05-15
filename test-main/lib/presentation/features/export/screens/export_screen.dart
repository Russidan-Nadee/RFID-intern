import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../blocs/export_bloc.dart';
import '../widgets/export_column_selector.dart';
import '../widgets/export_selected_assets.dart';
import '../widgets/export_preview_table.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../features/main/blocs/navigation_bloc.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _shouldScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      Provider.of<ExportBloc>(context, listen: false).setArguments(args);

      if (args != null && args['scrollToBottom'] == true) {
        _shouldScrollToBottom = true;
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
      appBar: AppBar(title: const Text('Export Assets Data'), elevation: 0),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<ExportBloc>(
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
                // ส่วนเลือกคอลัมน์
                ExportColumnSelector(
                  columnGroups: bloc.columnGroups,
                  onToggleColumn: bloc.toggleColumnSelection,
                  onSelectAllInGroup: bloc.selectAllColumnsInGroup,
                  onDeselectAllInGroup: bloc.deselectAllColumnsInGroup,
                  onSelectAll: bloc.selectAllColumns,
                  onDeselectAll: bloc.deselectAllColumns,
                  isColumnSelected: bloc.isColumnSelected,
                  areAllInGroupSelected: bloc.areAllColumnsInGroupSelected,
                ),

                const SizedBox(height: 24),

                // ส่วนรายการที่เลือก (ย้ายมาอยู่ต่อกับส่วนเลือกคอลัมน์)
                ExportSelectedAssets(
                  selectedAssets: bloc.selectedAssets,
                  onRemoveAsset: bloc.removeAsset,
                  onClearAll: bloc.clearSelectedAssets,
                  onAddMore: () {
                    Navigator.pushNamed(context, '/searchAssets');
                  },
                ),

                // ส่วนแสดงตัวอย่างข้อมูล
                if (bloc.selectedAssets.isNotEmpty &&
                    bloc.selectedColumns.isNotEmpty)
                  ExportPreviewTable(
                    previewAssets: bloc.previewAssets,
                    selectedColumns: bloc.selectedColumns,
                    totalSelectedAssets: bloc.selectedAssets.length,
                    estimatedFileSize: bloc.estimatedFileSize,
                    getAssetValueByColumnKey: bloc.getAssetValueByColumnKey,
                  ),

                // ปุ่ม Export
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: PrimaryButton(
                      text: 'Export CSV',
                      icon: Icons.file_download,
                      onPressed: () {
                        // นำทางไปยังหน้ายืนยันการส่งออก
                        Navigator.pushNamed(context, '/exportConfirmation');
                      },
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
}
