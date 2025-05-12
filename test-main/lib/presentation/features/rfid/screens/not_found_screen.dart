import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../../../../domain/entities/random_asset_info.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Asset Not Found')),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: AssetInfoCard(
                      assetInfo: rfidScanBloc.randomAssetInfo,
                    ),
                  ),
                ),
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
        const SizedBox(height: 16),
        Text(
          'ไม่พบอุปกรณ์ในระบบ',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'คุณสามารถบันทึกข้อมูลอุปกรณ์นี้เข้าระบบได้',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
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
    // เลือกปุ่มที่แสดงตามสถานะปัจจุบัน
    if (rfidScanBloc.status == RfidScanStatus.saving) {
      return const Center(child: CircularProgressIndicator());
    }

    if (rfidScanBloc.status == RfidScanStatus.saved) {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          const Text(
            'บันทึกข้อมูลสำเร็จ',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => _navigateToScanScreen(context),
            text: 'กลับไปหน้าสแกน',
            isDarkWhenPressed: true, // ให้มืดเฉพาะตอนกด
          ),
        ],
      );
    }

    return Column(
      children: [
        PrimaryButton(
          onPressed: () async {
            try {
              final success = await rfidScanBloc.saveAssetToDatabase();
              if (!success) {
                // แสดง SnackBar กรณีไม่สำเร็จ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'เกิดข้อผิดพลาด: ${rfidScanBloc.errorMessage}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('เกิดข้อผิดพลาด: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          text: 'บันทึกข้อมูล',
          isLoading: rfidScanBloc.status == RfidScanStatus.saving,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          onPressed: () => _navigateToScanScreen(context),
          text: 'กลับไปหน้าสแกน',
          isDarkWhenPressed:
              true, // แก้จาก color: Colors.grey เป็น isDarkWhenPressed: true
        ),
      ],
    );
  }

  // แยกการนำทางออกมาเป็นเมธอดแยก
  void _navigateToScanScreen(BuildContext context) {
    rfidScanBloc.resetStatus();
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.scanRfid,
      (route) => false, // ลบทุก route ก่อนหน้า
    );
  }
}

// สร้าง widget ที่ใช้ซ้ำได้สำหรับแสดงข้อมูลอุปกรณ์
class AssetInfoCard extends StatelessWidget {
  final RandomAssetInfo? assetInfo;

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
            const Text(
              'ข้อมูลอุปกรณ์',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
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
          Expanded(child: Text(value, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
  }
}
