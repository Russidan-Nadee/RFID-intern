import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class AssetInfoCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onViewDetails;

  const AssetInfoCard({
    Key? key,
    required this.asset,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.inventory,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          asset.itemName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          'Status: ${asset.status}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onViewDetails,
      ),
    );
  }
}
