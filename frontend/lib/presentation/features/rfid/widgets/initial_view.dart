// lib/presentation/features/rfid/widgets/initial_view.dart
import 'package:flutter/material.dart';
import '../blocs/rfid_scan_provider.dart';

class InitialView extends StatelessWidget {
  final RfidScanProvider bloc;
  final BuildContext context;

  const InitialView({required this.bloc, required this.context, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.nfc, size: 60, color: Colors.deepPurple.shade400),
          ),
          const SizedBox(height: 32),
          Text(
            'RFID Scanner',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'กดปุ่ม SCAN เพื่อเริ่มสแกน RFID',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => bloc.performScan(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SCAN',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
