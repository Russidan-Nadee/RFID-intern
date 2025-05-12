import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../models/asset_info.dart';  // สมมติว่ามีไฟล์นี้สำหรับข้อมูล AssetInfo

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<RfidScanBloc>(
          builder: (context, rfidScanBloc, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ไอคอนและข้อความแสดงว่าไม่พบอุปกรณ์
                const _HeaderSection(),
                const SizedBox(height: 24),
                
                // แสดงข้อมูลอุปกรณ์ที่สุ่ม
                AssetInfoCard(assetInfo: rfidScanBloc.randomAssetInfo),
                const SizedBox(height: 24),
                
                // ปุ่มการทำงาน
                _ActionButtons(rfidScanBloc: rfidScanBloc),
              ],
            );
          },
        ),
      ),
    );
  }
}

// แยกส่วนหัวออกมาเป็น widget แยก
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.search_off, size: 64, color: Colors.red),
        const SizedBox(height: 24),
        Text(
          'ไม่พบอุปกรณ์ในระบบ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// แยกปุ่มการทำงานเป็น widget แยก
class _ActionButtons extends StatelessWidget {
  final RfidScanBloc rfidScanBloc;

  const _ActionButtons({required this.rfidScanBloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          onPressed: () async {
            // แสดง loading indicator
            _showSavingDialog(context);
            
            try {
              // บันทึกข้อมูลลงฐานข้อมูล
              final success = await rfidScanBloc.saveAssetToDatabase();
              
              // ปิด dialog
              Navigator.pop(context);
              
              // แสดงผลการบันทึก
              _showResultSnackbar(
                context, 
                success ? 'บันทึกข้อมูลสำเร็จ' : 'บันทึกข้อมูลไม่สำเร็จ',
                success ? Colors.green : Colors.red,
              );
              
              // ถ้าบันทึกสำเร็จให้กลับไปหน้าสแกน
              if (success) {
                await Future.delayed(const Duration(seconds: 1));
                _navigateToScanScreen(context);
              }
            } catch (e) {
              // ปิด dialog และแสดงข้อผิดพลาด
              Navigator.pop(context);
              _showResultSnackbar(context, 'เกิดข้อผิดพลาด: $e', Colors.red);
            }
          },
          text: 'บันทึกข้อมูล',
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          onPressed: () => _navigateToScanScreen(context),
          text: 'กลับไปหน้าสแกน',
        ),
      ],
    );
  }
  
  // แสดง dialog ตอนกำลังบันทึกข้อมูล
  void _showSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังบันทึกข้อมูล...'),
          ],
        ),
      ),
    );
  }
  
  // แสดง snackbar แจ้งผลการบันทึก
  void _showResultSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // แยกการนำทางออกมาเป็นเมธอดแยก
  void _navigateToScanScreen(BuildContext context) {
    rfidScanBloc.resetStatus();
    Navigator.pushNamed(context, RouteConstants.scanRfid);
  }
}

// สร้าง widget ที่ใช้ซ้ำได้สำหรับแสดงข้อมูลอุปกรณ์
class AssetInfoCard extends StatelessWidget {
  final AssetInfo? assetInfo;

  const AssetInfoCard({Key? key, this.assetInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetInfo == null) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('ไม่มีข้อมูล'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID:', assetInfo!.id),
            _buildInfoRow('UID:', assetInfo!.uid),
            _buildInfoRow('หมวดหมู่:', assetInfo!.category),
            _buildInfoRow('แบรนด์:', assetInfo!.brand),
            _buildInfoRow('แผนก:', assetInfo!.department),
            _buildInfoRow('วันที่:', assetInfo!.date),
            _buildInfoRow('สถานะ:', assetInfo!.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}