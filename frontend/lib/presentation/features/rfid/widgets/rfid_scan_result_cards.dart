// Path: frontend/lib/presentation/features/rfid/widgets/rfid_scan_result_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';
import 'package:rfid_project/core/navigation/rfid_navigation_service.dart';
import 'package:rfid_project/presentation/features/rfid/bloc/rfid_scan_bloc.dart';

class RfidScanResultCards extends StatelessWidget {
  final EpcScanResult result;
  final AssetRepository assetRepository;

  const RfidScanResultCards({
    Key? key,
    required this.result,
    required this.assetRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (result.asset != null) {
      return _AssetInfoCard(
        asset: result.asset!,
        onTap: () => _navigateToAssetDetail(context, result.asset!),
      );
    } else {
      return _UnknownEpcCard(
        epc: result.epc!,
        onTap: () => _showAssetCreationForm(context, result.epc!),
        assetRepository: assetRepository,
      );
    }
  }

  void _navigateToAssetDetail(BuildContext context, Asset asset) async {
    try {
      final result = await RfidNavigationService.navigateToAssetDetail(
        context,
        asset,
      );

      if (!context.mounted) return;

      if (result != null && result['updated'] == true) {
        context.read<RfidScanBloc>().updateCardStatus(
          result['tagId'],
          result['newStatus'],
        );
      }
    } catch (e) {
      if (context.mounted) {
        RfidNavigationService.showError(
          context,
          'เกิดข้อผิดพลาดในการนำทาง: ${e.toString()}',
        );
      }
    }
  }

  void _showAssetCreationForm(BuildContext context, String epc) async {
    try {
      final result = await RfidNavigationService.navigateToAssetCreation(
        context,
        epc,
        assetRepository,
      );

      if (!context.mounted) return;

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 500));

        try {
          final newAsset = await assetRepository.findAssetByEpc(epc);

          if (newAsset != null && context.mounted) {
            context.read<RfidScanBloc>().updateUnknownEpcToAsset(epc, newAsset);

            RfidNavigationService.showSuccess(
              context,
              'สร้าง ${newAsset.itemName} สำเร็จ',
            );
          } else if (context.mounted) {
            RfidNavigationService.showSnackBarWithAction(
              context,
              'สร้างสำเร็จแต่ไม่สามารถอัปเดตหน้าจอได้ กรุณา refresh',
              'Refresh',
              () => context.read<RfidScanBloc>().refreshScanResults(),
              backgroundColor: Colors.orange,
            );
          }
        } catch (e) {
          debugPrint('Error fetching new asset: $e');

          if (context.mounted) {
            RfidNavigationService.showSnackBarWithAction(
              context,
              'สร้างสำเร็จแต่เกิดข้อผิดพลาดในการอัปเดตหน้าจอ: ${e.toString()}',
              'Refresh',
              () => context.read<RfidScanBloc>().refreshScanResults(),
              backgroundColor: Colors.orange,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error in asset creation form: $e');

      if (context.mounted) {
        RfidNavigationService.showError(
          context,
          'เกิดข้อผิดพลาดในการเตรียมข้อมูล: ${e.toString()}',
        );
      }
    }
  }
}

class _AssetInfoCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;

  const _AssetInfoCard({Key? key, required this.asset, required this.onTap})
    : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.deepPurple;
      case 'checked':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'disposed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: Colors.deepPurple.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.itemName ?? 'ไม่ระบุชื่อ',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${asset.status}',
                      style: TextStyle(
                        color: _getStatusColor(asset.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnknownEpcCard extends StatelessWidget {
  final String epc;
  final VoidCallback onTap;
  final AssetRepository assetRepository;

  const _UnknownEpcCard({
    Key? key,
    required this.epc,
    required this.onTap,
    required this.assetRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: Colors.red.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unknown Item',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: Unknown',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EPC: ${epc.length > 20 ? '${epc.substring(0, 20)}...' : epc}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}