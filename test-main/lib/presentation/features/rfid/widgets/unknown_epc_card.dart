// ใน lib/presentation/features/rfid/widgets/unknown_epc_card.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class UnknownEpcCard extends StatelessWidget {
  final String epc;
  final Asset? generatedAsset;
  final VoidCallback onTap;

  const UnknownEpcCard({
    Key? key,
    required this.epc,
    this.generatedAsset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        // ใช้สีแดงอ่อนสำหรับพื้นหลัง
        color: const Color(0xFFFDEDED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            // สีแดงเข้มขึ้นสำหรับไอคอน
            color: Colors.red.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.help_outline, color: Colors.red, size: 20),
          ),
        ),
        title: Text(
          generatedAsset?.itemName ?? 'Unknown Item',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${generatedAsset?.status ?? 'Unknown'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'EPC: $epc',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.red,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ไม่พบในฐานข้อมูล',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
