import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../widgets/scan_result_display.dart';
import '../../../../core/constants/route_constants.dart';
import '../blocs/rfid_scan_bloc.dart';
import '../../../../domain/repositories/asset_repository.dart';

class FoundScreen extends StatefulWidget {
  const FoundScreen({Key? key}) : super(key: key);

  @override
  State<FoundScreen> createState() => _FoundScreenState();
}

class _FoundScreenState extends State<FoundScreen> {
  bool _isUpdating = false;
  bool _updateSuccess = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    // รับ UID จาก arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String uid = arguments?['uid'] ?? 'Unknown';

    return ScreenContainer(
      appBar: AppBar(title: const Text('Asset Found')),
      child: Column(
        children: [
          // ส่วนแสดง UID
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Asset Found in System',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'UID: $uid',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // แสดงข้อมูลสินทรัพย์
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ScanResultDisplay(uid: uid),
            ),
          ),

          // แสดงข้อความเมื่ออัปเดตสำเร็จ
          if (_updateSuccess)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Status updated to "Checked In" successfully!',
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // แสดงข้อความเมื่อเกิดข้อผิดพลาด
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ปุ่มอัปเดตสถานะและปุ่มกลับ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // ปุ่มอัปเดตสถานะ
                PrimaryButton(
                  text: 'Update Status',
                  icon: Icons.update,
                  isLoading: _isUpdating,
                  onPressed: () {
                    // เรียกใช้ฟังก์ชันอัปเดตสถานะ
                    updateStatus(uid);
                  },
                ),
                const SizedBox(height: 12),

                // ปุ่มกลับ
                Consumer<RfidScanBloc>(
                  builder:
                      (context, bloc, _) => PrimaryButton(
                        text: 'Back to Scanner',
                        icon: Icons.arrow_back,
                        isDarkWhenPressed: true,
                        onPressed: () {
                          // รีเซ็ตสถานะของ bloc ก่อนกลับไปหน้าสแกน
                          bloc.resetStatus();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            RouteConstants.scanRfid,
                            (route) => false, // ลบทุก route ก่อนหน้า
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // แยกฟังก์ชันการอัปเดตสถานะออกมา
  void updateStatus(String uid) {
    // ตรวจสอบว่า UID ถูกต้องหรือไม่
    if (uid == 'Unknown') {
      setState(() {
        _errorMessage = 'Invalid UID';
      });
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorMessage = '';
    });

    try {
      // เรียกใช้ repository เพื่ออัปเดตสถานะ
      final repository = Provider.of<AssetRepository>(context, listen: false);
      final rfidBloc = Provider.of<RfidScanBloc>(context, listen: false);

      // ใช้ทั้ง then และ catchError เพื่อจัดการกับ Future
      repository
          .updateAssetStatus(uid, 'Checked In')
          .then((success) {
            setState(() {
              _isUpdating = false;
              _updateSuccess = success;
              if (!success) {
                _errorMessage = 'Failed to update status';
              } else {
                // เมื่ออัปเดตสำเร็จ ให้แสดงผลสักครู่ แล้วนำทางกลับไปยังหน้าสแกน
                Future.delayed(const Duration(seconds: 1), () {
                  // รีเซ็ตสถานะของ bloc ก่อนกลับไปหน้าสแกน
                  rfidBloc.resetStatus();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.scanRfid,
                    (route) => false, // ลบทุก route ก่อนหน้า
                  );
                });
              }
            });
          })
          .catchError((error) {
            setState(() {
              _isUpdating = false;
              _errorMessage = error.toString();
            });
          });
    } catch (e) {
      setState(() {
        _isUpdating = false;
        _errorMessage = e.toString();
      });
    }
  }
}
