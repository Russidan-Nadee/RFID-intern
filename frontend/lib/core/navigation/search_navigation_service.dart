// Path: frontend/lib/core/navigation/search_navigation_service.dart
import 'package:flutter/material.dart';
import '../../domain/entities/asset.dart';

class SearchNavigationService {
  // Navigate to asset detail screen
  static Future<void> navigateToAssetDetail(
    BuildContext context,
    Asset asset,
  ) async {
    try {
      if (asset.tagId.isEmpty) {
        throw Exception("ไม่พบรหัส Tag ID สำหรับสินทรัพย์นี้");
      }

      await Navigator.pushNamed(
        context,
        '/assetDetail',
        arguments: {'tagId': asset.tagId},
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'เกิดข้อผิดพลาดในการนำทาง: $e');
      }
    }
  }

  // Navigate to single asset export
  static Future<void> navigateToExport(
    BuildContext context,
    Asset asset, {
    bool scrollToBottom = false,
  }) async {
    try {
      await Navigator.pushNamed(
        context,
        '/export',
        arguments: {
          'assetId': asset.id,
          'assetUid': asset.tagId,
          'scrollToBottom': scrollToBottom,
        },
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'เกิดข้อผิดพลาดในการนำทางไปยังการส่งออก: $e');
      }
    }
  }

  // Navigate to multi-select export
  static Future<void> navigateToMultiExport(
    BuildContext context,
    List<Asset> selectedAssets,
  ) async {
    if (selectedAssets.isEmpty) {
      _showError(
        context,
        'กรุณาเลือกรายการก่อนทำการ Export',
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      await Navigator.pushNamed(
        context,
        '/export',
        arguments: {
          'assets': selectedAssets,
          'isMultiExport': true,
          'selectedCount': selectedAssets.length,
          'fromMultiSelect': true,
          'sourceScreen': 'searchAssets',
        },
      );

      if (context.mounted) {
        _showSuccess(
          context,
          'ส่งรายการ ${selectedAssets.length} รายการไปหน้า Export แล้ว',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(
          context,
          'เกิดข้อผิดพลาดในการไปหน้า Export: $e',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  // Show error snackbar
  static void _showError(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success snackbar
  static void _showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error with specific color and duration
  static void showError(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.red,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // Show success with specific color and duration
  static void showSuccess(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  // Show snackbar for multi-select validation
  static void showValidationError(BuildContext context, String message) {
    showError(
      context,
      message,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 2),
    );
  }
}
