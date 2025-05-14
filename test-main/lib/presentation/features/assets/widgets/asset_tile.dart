// lib/presentation/features/assets/widgets/asset_tile.dart
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
      child: InkWell(
        // เพิ่ม InkWell เพื่อให้คลิกแล้วไปยังหน้ารายละเอียด
        onTap: () {
          // แทนที่จะใช้เมธอด _navigateToDetail ให้ใส่โค้ดการนำทางตรงนี้
          // เพื่อให้แน่ใจว่าจะทำงานได้
          if (asset.uid.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ไม่พบ GUID ของสินทรัพย์นี้')),
            );
            return;
          }

          // นำทางไปยังหน้ารายละเอียด โดยส่ง uid แต่ใช้ชื่อคีย์เป็น 'guid'
          Navigator.pushNamed(
            context,
            '/assetDetail',
            arguments: {'guid': asset.uid},
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
            // เปลี่ยนจาก UID เป็น GUID
            _buildRow(Icons.qr_code, 'GUID: ${asset.uid}'),
            _buildRow(Icons.business, 'Brand: ${asset.brand}'),
            _buildRow(Icons.apartment, 'Department: ${asset.department}'),
            _buildRow(Icons.verified, 'Status: ${asset.status}'),
            _buildRow(Icons.calendar_today, 'Date: ${asset.date}'),

            // เพิ่มปุ่มดูรายละเอียดเพิ่มเติม
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // ใช้โค้ดเดียวกับ onTap ของ InkWell
                      if (asset.uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ไม่พบ GUID ของสินทรัพย์นี้'),
                          ),
                        );
                        return;
                      }

                      // นำทางไปยังหน้ารายละเอียด โดยส่ง uid แต่ใช้ชื่อคีย์เป็น 'guid'
                      Navigator.pushNamed(
                        context,
                        '/assetDetail',
                        arguments: {'guid': asset.uid},
                      );
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('ดูรายละเอียดเพิ่มเติม'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),

                  // เพิ่มปุ่ม Export
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/export',
                        arguments: {'assetId': asset.id, 'assetUid': asset.uid},
                      );
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export CSV'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
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
