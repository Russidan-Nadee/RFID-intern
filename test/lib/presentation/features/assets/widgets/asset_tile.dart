import 'package:flutter/material.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/entities/asset.dart';

class AssetTile extends StatelessWidget {
  final Asset asset;

  const AssetTile({Key? key, required this.asset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(
          getCategoryIcon(asset.category),
          size: 28,
          color: Colors.blueGrey,
        ),
        title: Row(
          children: [
            Text(
              asset.id,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              capitalize(asset.category),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        children: [
          _buildRow(Icons.qr_code, 'UID: ${asset.uid}'),
          _buildRow(Icons.business, 'Brand: ${asset.brand}'),
          _buildRow(Icons.apartment, 'Department: ${asset.department}'),
          _buildRow(Icons.verified, 'Status: ${asset.status}'),
          _buildRow(Icons.calendar_today, 'Date: ${asset.date}'),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
