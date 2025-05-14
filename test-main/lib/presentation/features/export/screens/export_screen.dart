import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../blocs/export_bloc.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../features/main/blocs/navigation_bloc.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _assetId;
  String? _assetUid;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // โหลดข้อมูลตัวอย่าง
      Provider.of<ExportBloc>(context, listen: false).loadPreviewData();

      // รับค่า arguments
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _assetId = args['assetId'];
          _assetUid = args['assetUid'];
        });
      }
    });
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
      appBar: AppBar(
        title: Text(
          _assetId != null ? 'Export Asset: $_assetId' : 'Export Assets Data',
        ),
        elevation: 0,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<ExportBloc>(
        builder: (context, bloc, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ข้อมูลสินทรัพย์
                if (_assetId != null && _assetUid != null)
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asset Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Asset ID: $_assetId'),
                          Text('Asset UID: $_assetUid'),
                        ],
                      ),
                    ),
                  ),

                // ตัวเลือกรูปแบบไฟล์
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Format',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Radio buttons สำหรับเลือกรูปแบบไฟล์
                        RadioListTile<String>(
                          title: Text('CSV Format'),
                          value: 'CSV',
                          groupValue: bloc.selectedFormat,
                          onChanged: (value) {
                            if (value != null) bloc.setSelectedFormat(value);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Excel Format (Coming Soon)'),
                          value: 'Excel',
                          groupValue: bloc.selectedFormat,
                          onChanged: null, // ปิดการใช้งานเนื่องจากยังไม่รองรับ
                        ),
                      ],
                    ),
                  ),
                ),

                // ตัวอย่างข้อมูล
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        if (bloc.status == ExportStatus.loading)
                          Center(child: CircularProgressIndicator())
                        else if (bloc.previewAssets.isEmpty)
                          Center(child: Text('No data available for export'))
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows:
                                  bloc.previewAssets.map((asset) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(asset.id)),
                                        DataCell(Text(asset.category)),
                                        DataCell(Text(asset.status)),
                                      ],
                                    );
                                  }).toList(),
                            ),
                          ),

                        if (bloc.assets.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Showing ${bloc.previewAssets.length} of ${bloc.assets.length} assets',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: PrimaryButton(
                    text: 'Export CSV',
                    icon: Icons.file_download,
                    isLoading: bloc.status == ExportStatus.exporting,
                    onPressed: () async {
                      await bloc.exportData();

                      if (bloc.status == ExportStatus.exportComplete &&
                          bloc.lastExportedFilePath != null) {
                        await Share.shareXFiles([
                          XFile(bloc.lastExportedFilePath!),
                        ], text: 'RFID Asset Export');
                      } else if (bloc.status == ExportStatus.error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${bloc.errorMessage}'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 24),

                // ประวัติการส่งออก
                Text(
                  'Export History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                if (bloc.exportHistory.isEmpty)
                  Center(child: Text('No export history'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bloc.exportHistory.length,
                    itemBuilder: (context, index) {
                      final item = bloc.exportHistory[index];
                      return ListTile(
                        leading: Icon(Icons.description),
                        title: Text(item['filename']),
                        subtitle: Text(
                          '${item['date']} • ${item['records']} records',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed: () async {
                            // แชร์ไฟล์จากประวัติ (ถ้ามีพาธ)
                            if (item.containsKey('path')) {
                              await Share.shareXFiles([
                                XFile(item['path']),
                              ], text: 'RFID Asset Export');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('File no longer available'),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
