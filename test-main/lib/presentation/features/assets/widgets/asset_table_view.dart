import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';
import '../blocs/asset_bloc.dart';

class AssetTableView extends StatelessWidget {
  final List<Asset> assets;
  final GlobalKey statusColumnKey;
  final AssetBloc bloc;

  const AssetTableView({
    Key? key,
    required this.assets,
    required this.statusColumnKey,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // สร้างรายการสถานะที่มีในข้อมูล
    final statuses = bloc.getAllStatuses();

    return ListView(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2), // ID
            1: FlexColumnWidth(1), // Category
            2: FlexColumnWidth(1.2), // Status
          },
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: [
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('ID')),
                  ),
                ),
                const TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Category')),
                  ),
                ),
                TableCell(
                  child: InkWell(
                    key: statusColumnKey,
                    onTap: () {
                      // แสดง dropdown สำหรับกรองตามสถานะ
                      _showStatusFilterMenu(context, statuses, bloc);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Status'),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color:
                                bloc.selectedStatus != null
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...List.generate(
              assets.length,
              (index) => _buildTableRow(assets[index], index),
            ),
          ],
        ),
      ],
    );
  }

  // สร้างแถวสำหรับตาราง
  TableRow _buildTableRow(Asset asset, int index) {
    final isChecked = asset.status == 'Checked In';
    final bgColor = index.isEven ? Colors.grey.shade100 : Colors.white;

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(asset.id)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(asset.category)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(asset.status),
                const SizedBox(width: 4),
                if (isChecked)
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // แสดง dropdown สำหรับกรองตามสถานะ
  void _showStatusFilterMenu(
    BuildContext context,
    List<String> statuses,
    AssetBloc bloc,
  ) {
    // ดึงตำแหน่งของคอลัมน์ Status
    final RenderBox? statusColumn =
        statusColumnKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;

    if (statusColumn != null && overlay != null) {
      // คำนวณตำแหน่งให้แสดง dropdown ใต้คอลัมน์ Status
      final statusColumnPos = statusColumn.localToGlobal(
        Offset.zero,
        ancestor: overlay,
      );
      final statusColumnSize = statusColumn.size;

      final RelativeRect position = RelativeRect.fromLTRB(
        statusColumnPos.dx,
        statusColumnPos.dy + statusColumnSize.height,
        statusColumnPos.dx + statusColumnSize.width,
        statusColumnPos.dy + statusColumnSize.height,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.clear,
                  color:
                      bloc.selectedStatus == null
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('All Statuses'),
              ],
            ),
          ),
          ...statuses.map(
            (status) => PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color:
                        bloc.selectedStatus == status
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(status),
                ],
              ),
            ),
          ),
        ],
      ).then((value) {
        if (value != null || value == null) {
          bloc.setStatusFilter(value);
        }
      });
    }
  }
}
