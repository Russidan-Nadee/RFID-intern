// Path: frontend/lib/presentation/features/search/widgets/asset_table_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/asset.dart';
import '../blocs/asset_bloc.dart';

class AssetTableView extends StatelessWidget {
  final List<Asset> assets;
  final GlobalKey statusColumnKey;
  final AssetBloc bloc;

  // =================== Multi-Select Parameters ===================
  final bool isMultiSelectMode;
  final Set<String> selectedAssetIds;
  final Function(String assetId, bool isSelected)? onAssetSelectionChanged;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearSelection;

  const AssetTableView({
    Key? key,
    required this.assets,
    required this.statusColumnKey,
    required this.bloc,

    // =================== Multi-Select Parameters ===================
    this.isMultiSelectMode = false,
    this.selectedAssetIds = const {},
    this.onAssetSelectionChanged,
    this.onSelectAll,
    this.onClearSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        children: [
          // หัวตาราง
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withAlpha(12),
              ),
            ),
            child: Table(
              columnWidths: _getColumnWidths(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: _buildHeaderCells(context),
                ),
              ],
            ),
          ),

          // แถวข้อมูล
          ...List.generate(
            assets.length,
            (index) => _buildTableRow(context, assets[index], index),
          ),
        ],
      ),
    );
  }

  // =================== Column Width Configuration ===================
  Map<int, TableColumnWidth> _getColumnWidths() {
    if (isMultiSelectMode) {
      return const {
        0: FixedColumnWidth(50), // Checkbox
        1: FlexColumnWidth(1.2), // ID
        2: FlexColumnWidth(1), // Category
        3: FlexColumnWidth(1.2), // Status
      };
    } else {
      return const {
        0: FlexColumnWidth(1.2), // ID
        1: FlexColumnWidth(1), // Category
        2: FlexColumnWidth(1.2), // Status
      };
    }
  }

  // =================== Header Cells Builder ===================
  List<Widget> _buildHeaderCells(BuildContext context) {
    List<Widget> cells = [];

    // เพิ่ม Select All Checkbox เมื่ออยู่ใน Multi-Select Mode
    if (isMultiSelectMode) {
      cells.add(_buildSelectAllHeaderCell(context));
    }

    // เพิ่ม Header Cells ปกติ
    cells.addAll([
      _buildHeaderCell(context, 'ID'),
      _buildHeaderCell(context, 'Category'),
      _buildStatusHeaderCell(context),
    ]);

    return cells;
  }

  // =================== Select All Header Cell ===================
  Widget _buildSelectAllHeaderCell(BuildContext context) {
    final bool isAllSelected =
        assets.isNotEmpty &&
        assets.every((asset) => selectedAssetIds.contains(asset.id));
    final bool isPartiallySelected =
        selectedAssetIds.isNotEmpty && !isAllSelected;

    return TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (isAllSelected) {
                onClearSelection?.call();
              } else {
                onSelectAll?.call();
              }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isAllSelected
                        ? Colors.deepPurpleAccent
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isAllSelected || isPartiallySelected
                          ? Colors.deepPurpleAccent
                          : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  isAllSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : isPartiallySelected
                      ? Icon(
                        Icons.remove,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      )
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  // สร้างเซลล์ส่วนหัว
  Widget _buildHeaderCell(BuildContext context, String text) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // สร้างเซลล์หัวสำหรับคอลัมน์ Status ที่สามารถกดเพื่อเปิด Dropdown
  Widget _buildStatusHeaderCell(BuildContext context) {
    return TableCell(
      key: statusColumnKey,
      child: Builder(
        builder: (context) {
          return InkWell(
            onTap: () {
              _showStatusFilterDropdown(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // แสดง Dropdown สำหรับเลือกสถานะที่ต้องการกรอง
  void _showStatusFilterDropdown(BuildContext context) {
    final RenderBox? renderBox =
        statusColumnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // ใช้เฉพาะสถานะ Available และ Checked
    final List<String> allStatuses = ['Available', 'Checked'];

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 200,
      ),
      items: [
        // เพิ่มตัวเลือก "All" เพื่อยกเลิกการกรอง
        PopupMenuItem<String>(
          value: 'ALL',
          child: Row(
            children: [
              Icon(
                Icons.clear_all,
                color:
                    bloc.selectedStatus == null
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Show All',
                style: TextStyle(
                  fontWeight:
                      bloc.selectedStatus == null
                          ? FontWeight.bold
                          : FontWeight.normal,
                  color:
                      bloc.selectedStatus == null
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                ),
              ),
            ],
          ),
        ),
        // เพิ่มรายการสถานะเฉพาะ Available และ Checked
        ...allStatuses.map((status) {
          final isSelected = bloc.selectedStatus == status;
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  status,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ).then((value) {
      if (value != null) {
        if (value == 'ALL') {
          // ยกเลิกการกรอง
          bloc.setStatusFilter(null);
        } else {
          // กรองตามสถานะที่เลือก
          bloc.setStatusFilter(value);
        }
      }
    });
  }

  // =================== Table Row Builder ===================
  Widget _buildTableRow(BuildContext context, Asset asset, int index) {
    final bool isSelected = selectedAssetIds.contains(asset.id);

    // ใช้สีพื้นหลังที่แตกต่างสำหรับรายการที่เลือก
    Color bgColor =
        isSelected && isMultiSelectMode
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.white;
    Color borderColor =
        isSelected && isMultiSelectMode
            ? Theme.of(context).primaryColor
            : Colors.grey.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isSelected && isMultiSelectMode ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isSelected && isMultiSelectMode
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleRowTap(context, asset),
          borderRadius: BorderRadius.circular(12),
          child: Table(
            columnWidths: _getColumnWidths(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: _buildDataCells(context, asset, isSelected)),
            ],
          ),
        ),
      ),
    );
  }

  // =================== Data Cells Builder ===================
  List<Widget> _buildDataCells(
    BuildContext context,
    Asset asset,
    bool isSelected,
  ) {
    List<Widget> cells = [];

    // เพิ่ม Checkbox Cell เมื่ออยู่ใน Multi-Select Mode
    if (isMultiSelectMode) {
      cells.add(_buildCheckboxCell(asset, isSelected));
    }

    // เพิ่ม Data Cells ปกติ
    cells.addAll([
      _buildDataCell(asset.id),
      _buildDataCell(asset.category),
      _buildStatusCell(context, asset.status, asset.status == 'Checked'),
    ]);

    return cells;
  }

  // =================== Checkbox Cell ===================
  Widget _buildCheckboxCell(Asset asset, bool isSelected) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: GestureDetector(
            onTap: () {
              onAssetSelectionChanged?.call(asset.id, !isSelected);
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors
                            .blue // แก้ตรงนี้
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected
                          ? Colors
                              .blue // แก้ตรงนี้
                          : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  // สร้างเซลล์ข้อมูลทั่วไป
  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // สร้างเซลล์สถานะ (เหมือนเดิม)
  Widget _buildStatusCell(BuildContext context, String status, bool isChecked) {
    String displayStatus = status;
    IconData statusIcon;

    if (status == 'Available') {
      statusIcon = Icons.close;
    } else {
      displayStatus = 'Checked';
      statusIcon = Icons.check;
    }

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayStatus,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(statusIcon, color: Colors.black87, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================== Event Handlers ===================
  void _handleRowTap(BuildContext context, Asset asset) {
    if (isMultiSelectMode) {
      // ในโหมด multi-select ให้ toggle selection
      final isSelected = selectedAssetIds.contains(asset.id);
      onAssetSelectionChanged?.call(asset.id, !isSelected);
    } else {
      // ในโหมด normal ให้ไปหน้ารายละเอียด
      context.read<AssetBloc>().navigateToAssetDetail(asset);
    }
  }
}
