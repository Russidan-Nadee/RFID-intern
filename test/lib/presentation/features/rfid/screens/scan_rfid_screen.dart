import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/rfid_scan_bloc.dart';

class ScanRfidScreen extends StatefulWidget {
  const ScanRfidScreen({Key? key}) : super(key: key);

  @override
  State<ScanRfidScreen> createState() => _ScanRfidScreenState();
}

class _ScanRfidScreenState extends State<ScanRfidScreen> {
  int _selectedIndex = 2; // Index for the Scan tab

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/viewAssets', '/export'][index],
    );
  }

  // แสดง dialog ตัวเลือกสำหรับการสแกน
  void _showScanOptionsDialog(BuildContext context) {
    final bloc = Provider.of<RfidScanBloc>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Scan Options'),
          content: const Text('Do you want to find an asset?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // ตั้งค่าว่าต้องการเจอสินทรัพย์
                bloc.setFindPreference(true);

                // ดำเนินการสแกน
                bloc.performScan(context);
              },
              child: const Text('Yes, Find Asset'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // ตั้งค่าว่าไม่ต้องการเจอสินทรัพย์
                bloc.setFindPreference(false);

                // ดำเนินการสแกน
                bloc.performScan(context);
              },
              child: const Text('No, Do Not Find Asset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Scan RFID')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<RfidScanBloc>(
        builder: (context, bloc, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error message if any
                if (bloc.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      bloc.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // ปุ่มสแกน RFID เพียงปุ่มเดียว
                PrimaryButton(
                  text: 'Scan',
                  icon: Icons.qr_code_scanner,
                  isLoading: bloc.status == RfidScanStatus.scanning,
                  onPressed: () {
                    _showScanOptionsDialog(context);
                  },
                ),

                const SizedBox(height: 32),

                // Additional instructions
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Scan an RFID tag to locate assets in the system.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
