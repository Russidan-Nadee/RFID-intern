// Path: frontend/lib/presentation/features/search/widgets/search_result_list.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class SearchResultList extends StatelessWidget {
  final List<Asset> assets;
  final Color cardColor;
  final Color primaryColor;
  final Function(Asset) onAssetSelected;
  final Function(Asset) onExportAsset;

  // =================== Multi-Select Parameters ===================
  final bool isMultiSelectMode;
  final Set<String> selectedAssetIds;
  final Function(String assetId, bool isSelected)? onAssetSelectionChanged;

  const SearchResultList({
    Key? key,
    required this.assets,
    required this.cardColor,
    required this.primaryColor,
    required this.onAssetSelected,
    required this.onExportAsset,

    // =================== Multi-Select Parameters ===================
    this.isMultiSelectMode = false,
    this.selectedAssetIds = const {},
    this.onAssetSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final isSelected = selectedAssetIds.contains(asset.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            // =================== Selection Visual Feedback ===================
            border:
                isSelected && isMultiSelectMode
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
            boxShadow:
                isSelected && isMultiSelectMode
                    ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: _buildListTile(asset, isSelected),
        );
      },
    );
  }

  Widget _buildListTile(Asset asset, bool isSelected) {
    return ListTile(
      // =================== Multi-Select Checkbox ===================
      leading:
          isMultiSelectMode
              ? _buildCheckboxWithIcon(asset, isSelected)
              : _buildIcon(),

      title: Row(
        children: [
          Text(
            asset.id, // แสดง ID จริงแทน index
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              asset.category,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
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
          if (isMultiSelectMode && isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'เลือกแล้ว',
                style: TextStyle(
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),

      // =================== Touch Handling ===================
      onTap: () => _handleTap(asset),
      onLongPress: isMultiSelectMode ? null : () => _handleLongPress(asset),
    );
  }

  // =================== Widget Builders ===================
  Widget _buildCheckboxWithIcon(Asset asset, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checkbox
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child:
              isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
        ),
        const SizedBox(width: 12),
        // Icon
        _buildIcon(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.inventory, color: primaryColor, size: 20),
      ),
    );
  }

  // =================== Event Handlers ===================
  void _handleTap(Asset asset) {
    if (isMultiSelectMode) {
      // ในโหมด multi-select ให้ toggle selection
      final isCurrentlySelected = selectedAssetIds.contains(asset.id);
      onAssetSelectionChanged?.call(asset.id, !isCurrentlySelected);
    } else {
      // ในโหมด normal ให้ไปหน้ารายละเอียด
      onAssetSelected(asset);
    }
  }

  void _handleLongPress(Asset asset) {
    // Long press ในโหมด normal จะเข้าสู่ multi-select mode
    // Logic นี้จะถูกจัดการในหน้า parent
    onAssetSelectionChanged?.call(asset.id, true);
  }
}
