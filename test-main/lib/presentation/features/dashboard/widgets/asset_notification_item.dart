import 'package:flutter/material.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../domain/entities/asset.dart';

class AssetNotificationItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color lightPrimaryColor;

  const AssetNotificationItem({
    Key? key,
    required this.asset,
    required this.onTap,
    required this.primaryColor,
    required this.lightPrimaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามสถานะโดยไม่ใช้ withOpacity
    Color statusColor = primaryColor;
    Color bgStatusColor = lightPrimaryColor;

    if (asset.status.toLowerCase() == 'checked in') {
      statusColor = Colors.green;
      bgStatusColor = const Color(0xFFE6F4E6); // สีเขียวอ่อน
    } else if (asset.status.toLowerCase() == 'in use') {
      statusColor = Colors.orange;
      bgStatusColor = const Color(0xFFF9F0E6); // สีส้มอ่อน
    } else if (asset.status.toLowerCase() == 'maintenance') {
      statusColor = Colors.red;
      bgStatusColor = const Color(0xFFF9E6E6); // สีแดงอ่อน
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgStatusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    getStatusIcon(asset.status),
                    color: statusColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${asset.category} - ${asset.status}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    TimeFormatter.timeAgo(asset.lastScanTime),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
