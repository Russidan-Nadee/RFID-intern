import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

const double _maxSelectedAssetsListHeight =
    400; // กำหนดความสูงสูงสุดสำหรับรายการที่เลือก

class ExportSelectedAssets extends StatelessWidget {
  final List<Asset> selectedAssets;
  final Function(Asset) onRemoveAsset;
  final VoidCallback onClearAll;
  final VoidCallback onAddMore;
  final VoidCallback onSelectAll;

  const ExportSelectedAssets({
    Key? key,
    required this.selectedAssets,
    required this.onRemoveAsset,
    required this.onClearAll,
    required this.onAddMore,
    required this.onSelectAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ไม่มีการจำกัดจำนวนรายการที่แสดงแล้ว
    final displayedAssets = selectedAssets;
    final hasMoreThanMaxHeight =
        selectedAssets.length * 56 >
        _maxSelectedAssetsListHeight; // ประมาณ 56 px ต่อรายการ

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'รายการที่เลือก (${selectedAssets.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      child: const Text('Select All'),
                      onPressed: onSelectAll,
                    ),
                    if (selectedAssets.isNotEmpty)
                      TextButton(
                        child: const Text('Clear All'),
                        onPressed: onClearAll,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (selectedAssets.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'ยังไม่มีรายการที่เลือก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: _maxSelectedAssetsListHeight,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics:
                      hasMoreThanMaxHeight
                          ? const ClampingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                  itemCount: displayedAssets.length,
                  itemBuilder: (context, index) {
                    final asset = displayedAssets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          // สามารถใส่ logic เมื่อกดที่รายการได้
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${asset.id} - ${asset.category}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${asset.status} - ${asset.currentLocation}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => onRemoveAsset(asset),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onAddMore,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'เพิ่มรายการ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
