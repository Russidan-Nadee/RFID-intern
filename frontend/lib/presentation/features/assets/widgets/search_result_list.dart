import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class SearchResultList extends StatelessWidget {
  final List<Asset> assets;
  final Color cardColor;
  final Color primaryColor;
  final Function(Asset) onAssetSelected;
  final Function(Asset) onExportAsset;

  const SearchResultList({
    Key? key,
    required this.assets,
    required this.cardColor,
    required this.primaryColor,
    required this.onAssetSelected,
    required this.onExportAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.inventory, color: primaryColor, size: 20),
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  asset.category,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'Status: ${asset.status}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add Export button for each asset
                IconButton(
                  icon: const Icon(Icons.file_download, color: Colors.green),
                  onPressed: () => onExportAsset(asset),
                  tooltip: 'Export this asset',
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () => onAssetSelected(asset),
          ),
        );
      },
    );
  }
}
