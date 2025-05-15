// lib/presentation/features/export/screens/export_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/lib/presentation/features/export/screens/export_confirmation_screen.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../blocs/export_bloc.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../features/main/blocs/navigation_bloc.dart';
import '../../../../domain/entities/asset.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _shouldScrollToBottom = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      Provider.of<ExportBloc>(context, listen: false).setArguments(args);

      if (args != null && args['fromSearch'] == true) {
        _shouldScrollToBottom = true;
      }

      if (_shouldScrollToBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 4) return; // ถ้าเป็นแท็บปัจจุบัน (Export) ไม่ต้องทำอะไร
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final navigationBloc = Provider.of<NavigationBloc>(context);
    final currentIndex = navigationBloc.currentIndex;

    return ScreenContainer(
      appBar: AppBar(title: const Text('Export Assets Data'), elevation: 0),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<ExportBloc>(
        builder: (context, bloc, _) {
          if (bloc.status == ExportStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนเลือกคอลัมน์
                _buildSelectColumnsSection(bloc),

                const SizedBox(height: 24),

                // ส่วนรายการที่เลือก (ย้ายมาอยู่ต่อกับส่วนเลือกคอลัมน์)
                _buildSelectedAssetsSection(bloc),

                // ส่วนแสดงตัวอย่างข้อมูล
                if (bloc.selectedAssets.isNotEmpty &&
                    bloc.selectedColumns.isNotEmpty)
                  _buildDataPreview(bloc),

                // ปุ่ม Export
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: PrimaryButton(
                      text: 'Export CSV',
                      icon: Icons.file_download,
                      onPressed: () {
                        // นำทางไปยังหน้ายืนยันการส่งออก
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const ExportConfirmationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // สร้างส่วนเลือกคอลัมน์
  Widget _buildSelectColumnsSection(ExportBloc bloc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกคอลัมน์สำหรับส่งออก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ปุ่มเลือกทั้งหมด/ยกเลิกทั้งหมด
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('เลือกทั้งหมด'),
                  onPressed: () {
                    bloc.selectAllColumns();
                  },
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('ยกเลิกทั้งหมด'),
                  onPressed: () {
                    bloc.deselectAllColumns();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // สร้างรายการคอลัมน์ตามกลุ่ม
            for (final groupEntry in bloc.columnGroups.entries)
              ExpansionTile(
                title: Text(
                  groupEntry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      child: const Text('เลือกทั้งหมด'),
                      onPressed: () {
                        bloc.selectAllColumnsInGroup(groupEntry.key);
                      },
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final column in groupEntry.value)
                          CheckboxListTile(
                            title: Text(_getColumnDisplayName(column)),
                            value: bloc.isColumnSelected(column),
                            onChanged: (value) {
                              bloc.toggleColumnSelection(column);
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // สร้างส่วนรายการที่เลือก
  Widget _buildSelectedAssetsSection(ExportBloc bloc) {
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
                  'รายการที่เลือก (${bloc.selectedAssets.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // ปุ่มล้างทั้งหมด
                if (bloc.selectedAssets.isNotEmpty)
                  TextButton(
                    child: const Text('ล้างทั้งหมด'),
                    onPressed: () {
                      bloc.clearSelectedAssets();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ถ้าไม่มีรายการที่เลือก
            if (bloc.selectedAssets.isEmpty)
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
                itemCount: bloc.selectedAssets.length,
                itemBuilder: (context, index) {
                  final asset = bloc.selectedAssets[index];

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
                              onPressed: () {
                                bloc.removeAsset(asset);
                              },
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
              onTap: () {
                // เด้งไปยังหน้าค้นหาเพื่อเลือกรายการเพิ่มเติม
                Navigator.pushNamed(context, '/searchAssets');
              },
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

  // สร้างส่วนแสดงตัวอย่างข้อมูล
  Widget _buildDataPreview(ExportBloc bloc) {
    final visibleColumns = bloc.selectedColumns.take(5).toList();
    final hasMoreColumns = bloc.selectedColumns.length > 5;
    final visibleAssets = bloc.selectedAssets.take(3).toList();
    final hasMoreAssets = bloc.selectedAssets.length > 3;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวอย่างข้อมูลที่จะส่งออก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ถ้าไม่มีข้อมูลหรือไม่มีคอลัมน์ที่เลือก
            if (bloc.selectedAssets.isEmpty || bloc.selectedColumns.isEmpty)
              const Center(child: Text('ไม่มีข้อมูลที่จะแสดงตัวอย่าง'))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    for (final column in visibleColumns)
                      DataColumn(label: Text(_getColumnDisplayName(column))),
                    if (hasMoreColumns) const DataColumn(label: Text('...')),
                  ],
                  rows: [
                    for (final asset in visibleAssets)
                      DataRow(
                        cells: [
                          for (final column in visibleColumns)
                            DataCell(Text(_getAssetValue(asset, column))),
                          if (hasMoreColumns) const DataCell(Text('...')),
                        ],
                      ),
                    if (hasMoreAssets)
                      DataRow(
                        cells: [
                          for (int i = 0; i < visibleColumns.length; i++)
                            const DataCell(Text('...')),
                          if (hasMoreColumns) const DataCell(Text('...')),
                        ],
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // แสดงข้อมูลสรุป
            Text(
              'จำนวนรายการที่จะส่งออก: ${bloc.selectedAssets.length} รายการ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'คอลัมน์ที่เลือก: ${bloc.selectedColumns.length} จาก ${bloc.availableColumns.length} คอลัมน์',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'ขนาดไฟล์โดยประมาณ: ${_calculateApproxFileSize(bloc)} KB',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // คำนวณขนาดไฟล์โดยประมาณ
  String _calculateApproxFileSize(ExportBloc bloc) {
    // คำนวณโดยประมาณ: จำนวนแถว x จำนวนคอลัมน์ x 30 ไบต์ต่อเซลล์ + 500 ไบต์สำหรับหัวตาราง
    final rowCount = bloc.selectedAssets.length;
    final colCount = bloc.selectedColumns.length;
    final approxSizeInBytes = (rowCount * colCount * 30) + 500;
    final approxSizeInKB = (approxSizeInBytes / 1024).toStringAsFixed(1);
    return approxSizeInKB;
  }

  // แสดงชื่อคอลัมน์แบบอ่านง่าย
  String _getColumnDisplayName(String column) {
    switch (column) {
      case 'id':
        return 'ID';
      case 'itemId':
        return 'Item ID';
      case 'tagId':
        return 'Tag ID';
      case 'epc':
        return 'EPC';
      case 'itemName':
        return 'Item Name';
      case 'category':
        return 'Category';
      case 'status':
        return 'Status';
      case 'tagType':
        return 'Tag Type';
      case 'value':
        return 'Value';
      case 'frequency':
        return 'Frequency';
      case 'currentLocation':
        return 'Location';
      case 'zone':
        return 'Zone';
      case 'lastScanTime':
        return 'Last Scan Time';
      case 'lastScanQuantity':
        return 'Last Scan Quantity';
      case 'batteryLevel':
        return 'Battery Level';
      case 'batchNumber':
        return 'Batch Number';
      case 'manufacturingDate':
        return 'Manufacturing Date';
      default:
        return column;
    }
  }

  // ดึงค่าจากสินทรัพย์ตามชื่อคอลัมน์
  String _getAssetValue(Asset asset, String column) {
    switch (column) {
      case 'id':
        return asset.id;
      case 'category':
        return asset.category;
      case 'status':
        return asset.status;
      case 'brand':
      case 'itemName':
        return asset.brand;
      case 'uid':
      case 'tagId':
      case 'epc':
        return asset.uid;
      case 'department':
      case 'currentLocation':
        return asset.department;
      case 'date':
      case 'lastScanTime':
        return asset.date;
      // สำหรับฟิลด์อื่นๆ ที่ไม่มีใน Asset Entity ให้คืนค่าว่าง
      default:
        return 'N/A';
    }
  }
}
