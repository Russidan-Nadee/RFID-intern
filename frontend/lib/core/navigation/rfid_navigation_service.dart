// Path: frontend/lib/core/navigation/rfid_navigation_service.dart
import 'package:flutter/material.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/asset_repository.dart';
import '../../presentation/features/rfid/screens/asset_creation_preview_screen.dart';

class RfidNavigationService {
  // Navigate to asset detail screen
  static Future<Map<String, dynamic>?> navigateToAssetDetail(
    BuildContext context,
    Asset asset,
  ) async {
    return await Navigator.pushNamed(
          context,
          '/assetDetail',
          arguments: {'tagId': asset.tagId},
        )
        as Map<String, dynamic>?;
  }

  // Navigate to asset creation form screen
  static Future<bool?> navigateToAssetCreation(
    BuildContext context,
    String epc,
    AssetRepository assetRepository,
  ) async {
    try {
      if (!context.mounted) return null;

      return await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (context) => AssetCreationFormScreen(
                epc: epc,
                assetRepository: assetRepository,
              ),
        ),
      );
    } catch (e) {
      // Handle error but don't show UI - let caller decide
      debugPrint('Error in navigateToAssetCreation: $e');
      return null;
    }
  }

  // Show error snackbar
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show snackbar with action
  static void showSnackBarWithAction(
    BuildContext context,
    String message,
    String actionLabel,
    VoidCallback onActionPressed, {
    Color? backgroundColor,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(label: actionLabel, onPressed: onActionPressed),
      ),
    );
  }
}
