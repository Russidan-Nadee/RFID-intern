// lib/presentation/features/assets/screens/asset_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../common_widgets/layouts/screen_container.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({Key? key}) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  String? _guid;
  bool _debugMode = true; // เปิดโหมด debug

  @override
  void initState() {
    super.initState();
    if (_debugMode) print('AssetDetailScreen - initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_debugMode) print('AssetDetailScreen - didChangeDependencies called');

    // รับค่า guid จาก arguments
    final Map<String, dynamic>? arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (_debugMode) print('AssetDetailScreen - Received arguments: $arguments');

    if (arguments != null) {
      setState(() {
        _guid = arguments['guid'] as String?;
      });

      if (_debugMode) print('AssetDetailScreen - Extracted GUID: "$_guid"');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_debugMode) print('AssetDetailScreen - build method called');

    return ScreenContainer(
      appBar: AppBar(title: const Text('รายละเอียดสินทรัพย์')),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'GUID ของสินทรัพย์:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                _guid ?? 'ไม่พบข้อมูล GUID',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('กลับไปหน้าค้นหา'),
            ),

            // แสดงข้อมูล Debug เพิ่มเติม (เฉพาะในโหมด Debug)
            if (_debugMode) ...[
              const SizedBox(height: 48),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Information:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arguments GUID: ${_guid ?? "null"}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
