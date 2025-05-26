import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/entities/epc_scan_result.dart';
import '../../../common_widgets/buttons/primary_button.dart';

class BulkUpdateDialog extends StatefulWidget {
  final List<EpcScanResult> scanResults;
  final Function(List<String> selectedTagIds) onConfirm;
  final VoidCallback onCancel;

  const BulkUpdateDialog({
    Key? key,
    required this.scanResults,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<BulkUpdateDialog> createState() => _BulkUpdateDialogState();
}

class _BulkUpdateDialogState extends State<BulkUpdateDialog> {
  Set<String> _selectedTagIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select Available items
    _preselectAvailableItems();
  }

  void _preselectAvailableItems() {
    for (final result in widget.scanResults) {
      if (result.asset != null && result.asset!.status == 'Available') {
        _selectedTagIds.add(result.asset!.tagId);
      }
    }
  }

  List<Asset> get _availableAssets {
    return widget.scanResults
        .where(
          (result) =>
              result.asset != null && result.asset!.status == 'Available',
        )
        .map((result) => result.asset!)
        .toList();
  }

  List<Asset> get _checkedAssets {
    return widget.scanResults
        .where(
          (result) => result.asset != null && result.asset!.status == 'Checked',
        )
        .map((result) => result.asset!)
        .toList();
  }

  List<String> get _unknownEpcs {
    return widget.scanResults
        .where((result) => result.asset == null && result.epc != null)
        .map((result) => result.epc!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6A5ACD);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.update, color: primaryColor, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Bulk Update Assets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Warning Banner (ถ้ามี unknown items)
            if (_unknownEpcs.isNotEmpty) _buildWarningBanner(),

            // Summary Text
            _buildSummaryText(),

            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'พบ ${_unknownEpcs.length} รายการที่ไม่รู้จัก จะไม่ถูก update',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryText() {
    final availableCount = _availableAssets.length;
    final checkedCount = _checkedAssets.length;
    final unknownCount = _unknownEpcs.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปการอัปเดต',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            'จะอัปเดต (Available → Checked)',
            availableCount,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            'เช็คแล้ว (ไม่เปลี่ยนแปลง)',
            checkedCount,
            Colors.blue,
          ),
          if (unknownCount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryItem(
              'อัปเดตไม่ได้ (ไม่รู้จัก)',
              unknownCount,
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    final hasSelection = _selectedTagIds.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            text: 'Confirm (${_selectedTagIds.length})',
            color: hasSelection ? primaryColor : Colors.grey,
            isLoading: _isLoading,
            onPressed:
                hasSelection && !_isLoading
                    ? () {
                      setState(() {
                        _isLoading = true;
                      });
                      widget.onConfirm(_selectedTagIds.toList());
                    }
                    : () {},
          ),
        ),
      ],
    );
  }
}
