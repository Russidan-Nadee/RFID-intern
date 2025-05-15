import 'package:flutter/material.dart';
import '../../../../domain/entities/asset.dart';

class ExportSelectedAssets extends StatelessWidget {
  final List<Asset> selectedAssets;
  final Function(Asset) onRemoveAsset;
  final VoidCallback onClearAll;
  final VoidCallback onAddMore;

  const ExportSelectedAssets({
    Key? key,
    required this.selectedAssets,
    required this.onRemoveAsset,
    required this.onClearAll,
    required this.onAddMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                // ปุ่มล้างทั้งหมด
                if (selectedAssets.isNotEmpty)
                  TextButton(
                    child: const Text('ล้างทั้งหมด'),
                    onPressed: onClearAll,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ถ้าไม่มีรายการที่เลือก
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
              // แสดงรายการที่เลือก
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedAssets.length,
                itemBuilder: (context, index) {
                  final asset = selectedAssets[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      onTap: () {
                        // สามารถกดที่แถวเพื่อดำเนินการบางอย่างได้
                        // เช่น แสดงรายละเอียดเพิ่มเติม
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
                                    '${asset.status} - ${asset.department}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ปุ่มลบ
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

            // ปุ่มเพิ่มรายการ (สี่เหลี่ยมที่มีเครื่องหมาย + อยู่ข้างใน)
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
