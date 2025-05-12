import 'package:flutter/material.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../widgets/scan_result_display.dart';

class FoundScreen extends StatelessWidget {
  const FoundScreen({Key? key}) : super(key: key);

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

          // ปุ่มกลับ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: 'Back to Scanner',
              icon: Icons.arrow_back,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
