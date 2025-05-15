import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../blocs/export_bloc.dart';
import '../widgets/export_preview_table.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  /*************  ✨ Windsurf Command ⭐  *************/
  /// Builds the export confirmation screen with an app bar, export details,
  /// data preview, and action buttons.
  ///
  /// This widget uses a [Consumer] to access the [ExportBloc] which manages
  /// the state and data related to the export process. The screen includes:
  /// - An app bar with a title.
  /// - A scrollable column displaying export details, a data preview, and
  ///   action buttons for confirming or canceling the export.
  ///
  /// The export details and data preview are built using the
  /// [_buildExportDetails] and [_buildDataPreview] helper methods respectively,
  /// while the action buttons are built using [_buildActionButtons].
  ///
  /// Params:
  /// - [context]: The [BuildContext] in which the widget is built.
  ///
  /// Returns:
  /// - A [Scaffold] widget containing the export confirmation UI.
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
              'รายละเอียดการส่งออก',
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
            Text('คอลัมน์ที่เลือก: ${bloc.selectedColumns.length} คอลัมน์'),
            Text('ขนาดไฟล์โดยประมาณ: ${bloc.estimatedFileSize} KB'),
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
              'ตัวอย่างข้อมูลที่จะส่งออก',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ถ้าไม่มีข้อมูลหรือไม่มีคอลัมน์ที่เลือก
            if (bloc.selectedAssets.isEmpty || bloc.selectedColumns.isEmpty)
              const Center(child: Text('ไม่มีข้อมูลที่จะแสดงตัวอย่าง'))
            else
              ExportPreviewTable(
                previewAssets: bloc.previewAssets,
                selectedColumns: bloc.selectedColumns,
                totalSelectedAssets: bloc.selectedAssets.length,
                estimatedFileSize: bloc.estimatedFileSize,
                getAssetValueByColumnKey: bloc.getAssetValueByColumnKey,
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
}
