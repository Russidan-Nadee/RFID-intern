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
              columnWidths: const {
                0: FlexColumnWidth(1.2), // ID
                1: FlexColumnWidth(1), // Category
                2: FlexColumnWidth(1.2), // Status
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    _buildHeaderCell(context, 'ID'),
                    _buildHeaderCell(context, 'Category'),
                    _buildHeaderCell(context, 'Status'),
                  ],
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

  // สร้างแถวสำหรับตาราง
  Widget _buildTableRow(BuildContext context, Asset asset, int index) {
    final bool isChecked = asset.status == 'Checked In';

    // กำหนดสีพื้นหลังตามสถานะ
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;

    if (asset.status == 'Checked In') {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade200;
    } else if (asset.status == 'Available') {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade200;
    } else if (asset.status == 'In Use') {
      bgColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
    } else if (asset.status == 'Maintenance') {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              '/assetDetail',
              arguments: {'guid': asset.uid},
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2), // ID
              1: FlexColumnWidth(1), // Category
              2: FlexColumnWidth(1.2), // Status
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  _buildDataCell(asset.id),
                  _buildDataCell(asset.category),
                  _buildStatusCell(context, asset.status, isChecked),
                ],
              ),
            ],
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

  // สร้างเซลล์สถานะ
  Widget _buildStatusCell(BuildContext context, String status, bool isChecked) {
    Color statusColor = Colors.grey;

    if (status == 'Checked In') {
      statusColor = Colors.green;
    } else if (status == 'Available') {
      statusColor = Colors.blue;
    } else if (status == 'In Use') {
      statusColor = Colors.orange;
    } else if (status == 'Maintenance') {
      statusColor = Colors.red;
    }

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (isChecked)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.check_circle,
                      color: statusColor,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
