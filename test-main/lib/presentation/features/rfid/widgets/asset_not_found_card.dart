// ใน lib/presentation/features/rfid/widgets/asset_not_found_card.dart
import 'package:flutter/material.dart';

class AssetNotFoundCard extends StatelessWidget {
  const AssetNotFoundCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลสินทรัพย์',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ไม่พบข้อมูลสินทรัพย์ที่ตรงกับ EPC นี้ในระบบ',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
