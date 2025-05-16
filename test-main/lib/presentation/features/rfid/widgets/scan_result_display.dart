import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../core/utils/icon_utils.dart';

class ScanResultDisplay extends StatefulWidget {
  final String uid;

  const ScanResultDisplay({Key? key, required this.uid}) : super(key: key);

  @override
  _ScanResultDisplayState createState() => _ScanResultDisplayState();
}

class _ScanResultDisplayState extends State<ScanResultDisplay> {
  late Future<Asset?> _assetFuture;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  void _loadAsset() {
    final repository = context.read<AssetRepository>();
    _assetFuture = repository.getAssetByUid(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Asset?>(
      future: _assetFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Asset details not available'));
        }

        final asset = snapshot.data!;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Asset ID with icon
                Row(
                  children: [
                    Icon(
                      getCategoryIcon(asset.category),
                      size: 24,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      asset.id,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Asset details
                _buildDetailRow('Category', asset.category),
                _buildDetailRow('Item Name', asset.itemName),
                _buildDetailRow('Location', asset.currentLocation),
                _buildDetailRow('Status', asset.status),
                _buildDetailRow('Last Scan', asset.lastScanTime),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
