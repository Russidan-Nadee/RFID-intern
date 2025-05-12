import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class AssetTableRow {
  final Asset asset;
  final int index;

  AssetTableRow({required this.asset, required this.index});

  // สร้างแถวสำหรับ Table แทน DataRow
  TableRow getTableRow() {
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

  // คงเมธอด getRow() ไว้สำหรับความเข้ากันได้กับโค้ดเดิม
  DataRow getRow() {
    final isChecked = asset.status == 'Checked In';

    return DataRow(
      color: WidgetStateProperty.all(
        index.isEven ? Colors.grey.shade100 : Colors.white,
      ),
      cells: [
        DataCell(Center(child: Text(asset.id))),
        DataCell(Center(child: Text(asset.category))),
        DataCell(Center(child: Text(asset.status))),
        DataCell(Center(child: Checkbox(value: isChecked, onChanged: null))),
      ],
    );
  }
}
