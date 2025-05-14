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
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('RFID Scanner')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<RfidScanBloc>(
        builder: (context, bloc, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // เหลือเพียงปุ่ม Scan เท่านั้น
                  PrimaryButton(
                    text: 'SCAN',
                    icon: Icons.qr_code_scanner,
                    isLoading: bloc.status == RfidScanStatus.scanning,
                    onPressed: () {
                      // สร้าง tag ID ตัวอย่างเพื่อการทดสอบ
                      // ในแอพจริงควรใช้การสแกนจริง
                      bloc.guidController.text =
                          'TEST-${DateTime.now().millisecondsSinceEpoch % 10000}';
                      bloc.performScan(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
