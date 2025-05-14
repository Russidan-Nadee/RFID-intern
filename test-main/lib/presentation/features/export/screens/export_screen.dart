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

class _ExportScreenState extends State<ExportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedLocation;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // รับค่า arguments
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // ส่ง arguments ไปยัง bloc
      Provider.of<ExportBloc>(context, listen: false).setArguments(args);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

          return Column(
            children: [
              // Tab Bar สำหรับสลับระหว่างเลือกข้อมูลและเลือกคอลัมน์
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'เลือกข้อมูล'),
                  Tab(text: 'เลือกคอลัมน์'),
                ],
              ),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: เลือกข้อมูล
                    _buildSelectDataTab(bloc),

                    // Tab 2: เลือกคอลัมน์
                    _buildSelectColumnsTab(bloc),
                  ],
                ),
              ),

              // ส่วนแสดงตัวอย่างข้อมูล

              // ปุ่ม Export
              // เปลี่ยนส่วนปุ่ม Export เป็น
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  text: 'Export CSV',
                  icon: Icons.file_download,
                  onPressed: () {
                    // นำทางไปยังหน้ายืนยันการส่งออก
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExportConfirmationScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // สร้างแท็บเลือกข้อมูล
  Widget _buildSelectDataTab(ExportBloc bloc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนค้นหาด่วน
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ค้นหาด่วน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // สถานะ
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'สถานะ',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Checked In',
                        child: Text('Checked In'),
                      ),
                      DropdownMenuItem(value: 'In Use', child: Text('In Use')),
                      DropdownMenuItem(
                        value: 'Maintenance',
                        child: Text('Maintenance'),
                      ),
                      DropdownMenuItem(
                        value: 'Damaged',
                        child: Text('Damaged'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // ตำแหน่ง
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'ตำแหน่ง',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedLocation,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
                      DropdownMenuItem(
                        value: 'Warehouse A',
                        child: Text('Warehouse A'),
                      ),
                      DropdownMenuItem(value: 'Office', child: Text('Office')),
                      DropdownMenuItem(
                        value: 'Production',
                        child: Text('Production'),
                      ),
                      DropdownMenuItem(
                        value: 'Storage',
                        child: Text('Storage'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // หมวดหมู่
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'หมวดหมู่',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('ทั้งหมด')),
                      DropdownMenuItem(
                        value: 'Raw Material',
                        child: Text('Raw Material'),
                      ),
                      DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                      DropdownMenuItem(value: 'Mouse', child: Text('Mouse')),
                      DropdownMenuItem(
                        value: 'Monitor',
                        child: Text('Monitor'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // ปุ่มค้นหา
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text('ค้นหา'),
                      onPressed: () {
                        bloc.searchAssets(
                          status: _selectedStatus,
                          location: _selectedLocation,
                          category: _selectedCategory,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ผลการค้นหา
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ผลการค้นหา',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (bloc.previewAssets.isNotEmpty)
                        ElevatedButton(
                          child: const Text('เลือกทั้งหมด'),
                          onPressed: () {
                            bloc.addAssets(bloc.previewAssets);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (bloc.previewAssets.isEmpty)
                    const Center(child: Text('ไม่พบรายการที่ตรงกับเงื่อนไข'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloc.previewAssets.length,
                      itemBuilder: (context, index) {
                        final asset = bloc.previewAssets[index];
                        final isSelected = bloc.isAssetSelected(asset);

                        return ListTile(
                          title: Text('${asset.id} - ${asset.category}'),
                          subtitle: Text(
                            '${asset.status} - ${asset.department}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected
                                  ? Icons.remove_circle
                                  : Icons.add_circle,
                              color: isSelected ? Colors.red : Colors.green,
                            ),
                            onPressed: () {
                              bloc.toggleAssetSelection(asset);
                            },
                          ),
                          onTap: () {
                            bloc.toggleAssetSelection(asset);
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // รายการที่เลือก
          Card(
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

                  if (bloc.selectedAssets.isEmpty)
                    const Center(child: Text('ยังไม่มีรายการที่เลือก'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bloc.selectedAssets.length,
                      itemBuilder: (context, index) {
                        final asset = bloc.selectedAssets[index];

                        return ListTile(
                          title: Text('${asset.id} - ${asset.category}'),
                          subtitle: Text(
                            '${asset.status} - ${asset.department}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              bloc.removeAsset(asset);
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // สร้างแท็บเลือกคอลัมน์
  Widget _buildSelectColumnsTab(ExportBloc bloc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          const SizedBox(height: 8),

          // สร้างรายการคอลัมน์ตามกลุ่ม
          for (final groupEntry in bloc.columnGroups.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ExpansionTile(
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
            ),
        ],
      ),
    );
  }

  // สร้างส่วนแสดงตัวอย่างข้อมูล
  Widget _buildDataPreview(ExportBloc bloc) {
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
                    for (final column in bloc.selectedColumns.take(5))
                      DataColumn(label: Text(_getColumnDisplayName(column))),
                    if (bloc.selectedColumns.length > 5)
                      const DataColumn(label: Text('...')),
                  ],
                  rows: [
                    for (final asset in bloc.selectedAssets.take(3))
                      DataRow(
                        cells: [
                          for (final column in bloc.selectedColumns.take(5))
                            DataCell(Text(_getAssetValue(asset, column))),
                          if (bloc.selectedColumns.length > 5)
                            const DataCell(Text('...')),
                        ],
                      ),
                    if (bloc.selectedAssets.length > 3)
                      const DataRow(
                        cells: [
                          DataCell(Text('...')),
                          DataCell(Text('...')),
                          DataCell(Text('...')),
                          DataCell(Text('...')),
                          DataCell(Text('...')),
                          DataCell(Text('...')),
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
