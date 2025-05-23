import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/entities/export_column.dart';

class ExportPreviewTable extends StatelessWidget {
  final List<Asset> previewAssets;
  final List<ExportColumn> selectedColumns;
  final int totalSelectedAssets;
  final int estimatedFileSize;
  final Function(Asset, String) getAssetValueByColumnKey;

  const ExportPreviewTable({
    Key? key,
    required this.previewAssets,
    required this.selectedColumns,
    required this.totalSelectedAssets,
    required this.estimatedFileSize,
    required this.getAssetValueByColumnKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleColumns = selectedColumns.take(5).toList();
    final hasMoreColumns = selectedColumns.length > 5;
    final visibleAssets = previewAssets.take(3).toList();
    final hasMoreAssets = totalSelectedAssets > 3;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวอย่างข้อมูลที่จะส่งออก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ถ้าไม่มีข้อมูลหรือไม่มีคอลัมน์ที่เลือก
            if (totalSelectedAssets == 0 || selectedColumns.isEmpty)
              const Center(child: Text('ไม่มีข้อมูลที่จะแสดงตัวอย่าง'))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    for (final column in visibleColumns)
                      DataColumn(label: Text(column.displayName)),
                    if (hasMoreColumns) const DataColumn(label: Text('...')),
                  ],
                  rows: [
                    for (final asset in visibleAssets)
                      DataRow(
                        cells: [
                          for (final column in visibleColumns)
                            DataCell(
                              Text(
                                getAssetValueByColumnKey(
                                  asset,
                                  column.key,
                                ).toString(),
                              ),
                            ),
                          if (hasMoreColumns) const DataCell(Text('...')),
                        ],
                      ),
                    if (hasMoreAssets)
                      DataRow(
                        cells: [
                          for (int i = 0; i < visibleColumns.length; i++)
                            const DataCell(Text('...')),
                          if (hasMoreColumns) const DataCell(Text('...')),
                        ],
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // แสดงข้อมูลสรุป
            Text(
              'จำนวนรายการที่จะส่งออก: $totalSelectedAssets รายการ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'คอลัมน์ที่เลือก: ${selectedColumns.length} คอลัมน์',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'ขนาดไฟล์โดยประมาณ: $estimatedFileSize KB',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
