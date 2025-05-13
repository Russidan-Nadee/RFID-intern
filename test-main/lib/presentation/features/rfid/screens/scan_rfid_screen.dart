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

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('ค้นหา RFID')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<RfidScanBloc>(
        builder: (context, bloc, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ข้อความคำแนะนำ
                const Text(
                  'กรอก GUID หรือ รหัสที่ต้องการค้นหา',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // ช่องกรอก GUID
                TextField(
                  controller: bloc.guidController,
                  decoration: InputDecoration(
                    labelText: 'GUID / รหัสสินทรัพย์',
                    hintText: 'เช่น JR-7281, WP-0609, TR-5442 เป็นต้น',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),

                const SizedBox(height: 24),

                // Error message if any
                if (bloc.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      bloc.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // ปุ่มค้นหา
                PrimaryButton(
                  text: 'ค้นหา',
                  icon: Icons.search,
                  isLoading: bloc.status == RfidScanStatus.scanning,
                  onPressed: () {
                    bloc.performScan(context);
                  },
                ),

                const SizedBox(height: 32),

                // คำแนะนำเพิ่มเติม
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'คุณสามารถป้อน GUID หรือรหัสที่ปรากฏบนสินทรัพย์เพื่อตรวจสอบข้อมูล',
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
