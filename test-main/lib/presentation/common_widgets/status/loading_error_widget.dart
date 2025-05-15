import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';

class LoadingWidget extends StatelessWidget {
  final Color primaryColor;
  
  const LoadingWidget({
    Key? key, 
    this.primaryColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }
}

// เปลี่ยนชื่อจาก ErrorWidget เป็น ErrorDisplayWidget เพื่อไม่ให้ชื่อซ้ำกับ Flutter
class ErrorDisplayWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final Color primaryColor;

  const ErrorDisplayWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.primaryColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('เกิดข้อผิดพลาด: $errorMessage'),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: onRetry,
            text: 'ลองใหม่',
            icon: Icons.refresh,
            color: primaryColor,
          ),
        ],
      ),
    );
  }
}