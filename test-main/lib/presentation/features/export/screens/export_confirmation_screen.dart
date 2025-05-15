// lib/presentation/features/export/screens/export_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/presentation/common_widgets/buttons/primary_button.dart';
import 'package:rfid_project/presentation/features/export/blocs/export_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ExportConfirmationScreen extends StatefulWidget {
  const ExportConfirmationScreen({Key? key}) : super(key: key);

  @override
  _ExportConfirmationScreenState createState() =>
      _ExportConfirmationScreenState();
}

class _ExportConfirmationScreenState extends State<ExportConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ยืนยันการส่งออก'), elevation: 0),
      body: Consumer<ExportBloc>(
        builder: (context, bloc, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนแสดงรายละเอียดการส่งออก
                _buildExportDetails(bloc),

                // ส่วนแสดงตัวอย่างข้อมูล
                _buildDataPreview(bloc),

                // ส่วนปุ่มยืนยันและยกเลิก
                _buildActionButtons(context, bloc),
              ],
            ),
          );
        },
      ),
    );
  }

  // สร้างส่วนแสดงรายละเอียดการส่งออก
  Widget _buildExportDetails(ExportBloc bloc) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวอย่างข้อมูลที่จะส่งออก',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),

            const Text('ไฟล์ข้อมูลที่จะส่งออก: CSV'),
            Text(
              'จำนวนรายการที่จะส่งออก: ${bloc.selectedAssets.length} รายการ',
            ),
            Text(
              'คอลัมน์ที่เลือก: ${bloc.selectedColumns.length} จาก ${bloc.availableColumns.length} คอลัมน์',
            ),
            Text('ขนาดไฟล์โดยประมาณ: ${_calculateApproxFileSize(bloc)} KB'),
          ],
        ),
      ),
    );
  }

  // สร้างส่วนแสดงตัวอย่างข้อมูล
  Widget _buildDataPreview(ExportBloc bloc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวอย่างข้อมูล',
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
                    for (final asset in bloc.selectedAssets.take(5))
                      DataRow(
                        cells: [
                          for (final column in bloc.selectedColumns.take(5))
                            DataCell(Text(_getAssetValue(asset, column))),
                          if (bloc.selectedColumns.length > 5)
                            const DataCell(Text('...')),
                        ],
                      ),
                    if (bloc.selectedAssets.length > 5)
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
          ],
        ),
      ),
    );
  }

  // สร้างส่วนปุ่มดำเนินการ
  Widget _buildActionButtons(BuildContext context, ExportBloc bloc) {
    return Row(
      children: [
        // ปุ่มยกเลิก
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // กลับไปหน้าก่อนหน้า
            },
            child: const Text('ยกเลิก'),
          ),
        ),
        const SizedBox(width: 16),

        // ปุ่มยืนยัน
        Expanded(
          child: PrimaryButton(
            text: 'ยืนยันการส่งออก',
            icon: Icons.file_download,
            isLoading: bloc.status == ExportStatus.exporting,
            onPressed: () async {
              await bloc.exportData();

              if (bloc.status == ExportStatus.exportComplete &&
                  bloc.lastExportedFilePath != null) {
                await Share.shareXFiles([
                  XFile(bloc.lastExportedFilePath!),
                ], text: 'RFID Asset Export');

                // กลับไปหน้าก่อนหน้าหลังจากส่งออกเสร็จ
                Navigator.pop(context);
              } else if (bloc.status == ExportStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${bloc.errorMessage}')),
                );
              }
            },
          ),
        ),
      ],
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
