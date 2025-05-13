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
    // รับ UID จาก arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String uid = arguments?['uid'] ?? 'Unknown';

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

                // แสดงข้อมูล UID ที่สแกน
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ข้อมูลการสแกน',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildInfoRow('UID ที่สแกน:', uid),
                        const Text(
                          'ไม่พบข้อมูลในระบบ กรุณาติดต่อเจ้าหน้าที่เพื่อเพิ่มข้อมูลในระบบ',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ปุ่มกลับ
                PrimaryButton(
                  onPressed: () => _navigateToScanScreen(context, rfidScanBloc),
                  text: 'กลับไปหน้าสแกน',
                  isDarkWhenPressed: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // แยกการนำทางออกมาเป็นเมธอดแยก
  void _navigateToScanScreen(BuildContext context, RfidScanBloc rfidScanBloc) {
    rfidScanBloc.resetStatus();
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteConstants.scanRfid,
      (route) => false, // ลบทุก route ก่อนหน้า
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
          'UID นี้ยังไม่มีในฐานข้อมูล',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
