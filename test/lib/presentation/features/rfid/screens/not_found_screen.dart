import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rfidScanBloc = Provider.of<RfidScanBloc>(context);

    return ScreenContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'ไม่พบอุปกรณ์ในระบบ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildInfoCard(rfidScanBloc),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                // สุ่มข้อมูลใหม่
                await rfidScanBloc.generateNewRandomAsset();
              },
              text: 'สุ่มข้อมูลใหม่',
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: () {
                rfidScanBloc.resetStatus();
                Navigator.pushNamed(context, RouteConstants.scanRfid);
              },
              text: 'กลับไปหน้าสแกน',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RfidScanBloc bloc) {
    // เลือกข้อมูลที่จะแสดง
    final infoData = bloc.randomAssetInfo;

    if (infoData == null) {
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
            _buildInfoRow('ID:', infoData.id),
            _buildInfoRow('UID:', infoData.uid),
            _buildInfoRow('หมวดหมู่:', infoData.category),
            _buildInfoRow('แบรนด์:', infoData.brand),
            _buildInfoRow('แผนก:', infoData.department),
            _buildInfoRow('วันที่:', infoData.date),
            _buildInfoRow('สถานะ:', infoData.status),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
