import 'package:flutter/material.dart';
import '../../../../domain/entities/export_column.dart';

class ExportColumnSelector extends StatelessWidget {
  final Map<String, List<ExportColumn>> columnGroups;
  final Function(String) onToggleColumn;
  final Function(String) onSelectAllInGroup;
  final Function(String) onDeselectAllInGroup;
  final Function() onSelectAll;
  final Function() onDeselectAll;
  final Function(String) isColumnSelected;
  final Function(String) areAllInGroupSelected;

  const ExportColumnSelector({
    Key? key,
    required this.columnGroups,
    required this.onToggleColumn,
    required this.onSelectAllInGroup,
    required this.onDeselectAllInGroup,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.isColumnSelected,
    required this.areAllInGroupSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกคอลัมน์สำหรับส่งออก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ปุ่มเลือกทั้งหมด/ยกเลิกทั้งหมด
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('เลือกทั้งหมด'),
                  onPressed: onSelectAll,
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('ยกเลิกทั้งหมด'),
                  onPressed: onDeselectAll,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // สร้างรายการคอลัมน์ตามกลุ่ม
            for (final groupEntry in columnGroups.entries)
              ExpansionTile(
                title: Text(
                  groupEntry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: Text(
                        areAllInGroupSelected(groupEntry.key)
                            ? 'ยกเลิกทั้งหมด'
                            : 'เลือกทั้งหมด',
                      ),
                      onPressed: () {
                        if (areAllInGroupSelected(groupEntry.key)) {
                          onDeselectAllInGroup(groupEntry.key);
                        } else {
                          onSelectAllInGroup(groupEntry.key);
                        }
                      },
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final column in groupEntry.value)
                          CheckboxListTile(
                            title: Text(column.displayName),
                            value: isColumnSelected(column.key),
                            onChanged: (value) {
                              onToggleColumn(column.key);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
