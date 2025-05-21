import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';

/// บริการกลางสำหรับการจัดการและแสดงข้อผิดพลาดทั่วทั้งแอป
class ErrorHandler {
  /// แปลง HTTP status code เป็น Exception ที่เหมาะสม
  static AppException handleApiError(
    int statusCode,
    String message,
    String? url,
  ) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message, url);
      case 401:
      case 403:
        return UnauthorisedException(message, url);
      case 404:
        return NotFoundException(message, url);
      case 409:
        return ConflictException(message, url);
      case 500:
      default:
        return FetchDataException(message, url);
    }
  }

  /// แสดงข้อผิดพลาดผ่าน SnackBar
  static void showError(BuildContext context, dynamic error) {
    // แปลง error เป็น AppException ถ้ายังไม่ใช่
    final AppException exception = _convertToAppException(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.message),
        backgroundColor: _getErrorColor(exception),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// แสดงข้อผิดพลาดผ่าน Dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error,
  ) async {
    // แปลง error เป็น AppException ถ้ายังไม่ใช่
    final AppException exception = _convertToAppException(error);

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getErrorTitle(exception)),
            content: Text(exception.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  /// แสดงข้อผิดพลาดพร้อมตัวเลือกให้ผู้ใช้ลองใหม่
  static Future<bool> showRetryDialog(
    BuildContext context,
    dynamic error, {
    String retryText = 'ลองใหม่',
    String cancelText = 'ยกเลิก',
  }) async {
    // แปลง error เป็น AppException ถ้ายังไม่ใช่
    final AppException exception = _convertToAppException(error);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getErrorTitle(exception)),
            content: Text(exception.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(retryText),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  /// แปลง error ทุกประเภทเป็น AppException เพื่อความสม่ำเสมอ
  static AppException _convertToAppException(dynamic error) {
    if (error is AppException) {
      return error;
    } else if (error is Exception) {
      return AppException(error.toString(), 'Exception');
    } else {
      return AppException(
        error?.toString() ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
        'Error',
      );
    }
  }

  /// ดึงสีที่เหมาะสมกับประเภทข้อผิดพลาด
  static Color _getErrorColor(AppException error) {
    if (error is BadRequestException || error is ValidationException) {
      return Colors.orange;
    } else if (error is NotFoundException) {
      return Colors.amber.shade900;
    } else if (error is UnauthorisedException) {
      return Colors.red.shade800;
    } else if (error is ConflictException) {
      return Colors.deepPurple;
    } else if (error is DatabaseException) {
      return Colors.indigo;
    } else {
      return Colors.red;
    }
  }

  /// ดึงหัวข้อที่เหมาะสมกับประเภทข้อผิดพลาด
  static String _getErrorTitle(AppException error) {
    if (error is BadRequestException || error is ValidationException) {
      return 'ข้อมูลไม่ถูกต้อง';
    } else if (error is NotFoundException) {
      return 'ไม่พบข้อมูล';
    } else if (error is UnauthorisedException) {
      return 'ไม่ได้รับอนุญาต';
    } else if (error is ConflictException) {
      return 'ข้อมูลขัดแย้ง';
    } else if (error is DatabaseException) {
      return 'ฐานข้อมูลมีปัญหา';
    } else if (error is FetchDataException) {
      return 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์';
    } else {
      return 'เกิดข้อผิดพลาด';
    }
  }

  /// บันทึก error ลงใน console (ในอนาคตอาจส่งไปที่บริการ logging)
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    final AppException exception = _convertToAppException(error);
    print('ERROR: ${exception.toString()}');
    if (stackTrace != null) {
      print('STACK TRACE: $stackTrace');
    }

    // ในอนาคตอาจส่งข้อมูลไปยังบริการ logging ภายนอก เช่น
    // FirebaseCrashlytics, Sentry, AppCenter เป็นต้น
  }
}
