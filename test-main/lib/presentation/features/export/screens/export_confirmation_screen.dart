import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/export_bloc.dart';

class ExportConfirmationScreen extends StatelessWidget {
  const ExportConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6A5ACD);
    final cardColor = const Color(0xFFF5F5F8);
    final lightPrimaryColor = const Color(0xFFE6E4F4);

    return ScreenContainer(
      appBar: AppBar(
        title: Text(
          'ยืนยันการส่งออก',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      backgroundColor: Colors.white,
      child: Consumer<ExportBloc>(
        builder: (context, bloc, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExportDetails(bloc, primaryColor),
                _buildDataPreview(bloc, primaryColor, cardColor),
                _buildActionButtons(context, bloc, primaryColor),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportDetails(ExportBloc bloc, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รายละเอียดการส่งออก',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text('ไฟล์ข้อมูลที่จะส่งออก: CSV'),
          Text('จำนวนรายการที่จะส่งออก: ${bloc.selectedAssets.length} รายการ'),
          Text('คอลัมน์ที่เลือก: ${bloc.selectedColumns.length} คอลัมน์'),
          Text('ขนาดไฟล์โดยประมาณ: ${bloc.estimatedFileSize} KB'),
        ],
      ),
    );
  }

  Widget _buildDataPreview(
    ExportBloc bloc,
    Color primaryColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตัวอย่างข้อมูล',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (bloc.selectedAssets.isEmpty || bloc.selectedColumns.isEmpty)
            const Center(child: Text('ไม่มีข้อมูลที่จะแสดงตัวอย่าง'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      for (final column in bloc.selectedColumns)
                        DataColumn(label: Text(column.displayName)),
                    ],
                    rows: [
                      for (final asset in bloc.selectedAssets)
                        DataRow(
                          cells: [
                            for (final column in bloc.selectedColumns)
                              DataCell(
                                Text(
                                  bloc
                                      .getAssetValueByColumnKey(
                                        asset,
                                        column.key,
                                      )
                                      .toString(),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ExportBloc bloc,
    Color primaryColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: primaryColor),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('ยกเลิก', style: TextStyle(color: primaryColor)),
          ),
        ),
        const SizedBox(width: 16),
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
}
