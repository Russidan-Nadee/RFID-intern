// lib/presentation/features/rfid/blocs/rfid_scan_bloc.dart
import 'package:flutter/material.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/data/models/asset_model.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../domain/usecases/assets/bulk_update_assets_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';

/// สถานะการสแกน RFID
enum RfidScanStatus {
  initial, // สถานะเริ่มต้น
  scanning, // กำลังสแกน
  scanned, // สแกนเสร็จแล้ว (พบหรือไม่พบก็ได้)
  bulkUpdating, // กำลัง bulk update
  bulkUpdateComplete, // bulk update เสร็จแล้ว
  error, // เกิดข้อผิดพลาด
}

class RfidScanProvider extends ChangeNotifier {
  final ScanRfidUseCase _scanRfidUseCase;
  final BulkUpdateAssetsUseCase _bulkUpdateAssetsUseCase;

  // =================== Core State Variables ===================
  RfidScanStatus _status = RfidScanStatus.initial;
  List<EpcScanResult> _scanResults = [];
  String _errorMessage = '';
  BulkUpdateResult? _bulkUpdateResult;

  // =================== Constructor ===================
  RfidScanProvider(this._scanRfidUseCase, this._bulkUpdateAssetsUseCase);

  // =================== Basic Getters ===================
  RfidScanStatus get status => _status;
  List<EpcScanResult> get scanResults => _scanResults;
  String get errorMessage => _errorMessage;
  BulkUpdateResult? get bulkUpdateResult => _bulkUpdateResult;

  // =================== Scan Operations ===================

  /// ดำเนินการสแกน RFID หลัก
  Future<void> performScan(BuildContext context) async {
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      // เรียกใช้ UseCase เพื่อสแกน
      final results = await _scanRfidUseCase.execute(context);

      // บันทึกผลลัพธ์
      _scanResults = results;

      if (_scanResults.isEmpty) {
        throw RfidScanException("ไม่พบผลลัพธ์การสแกน");
      } else if (_scanResults.first.success == false) {
        throw RfidScanException(_scanResults.first.errorMessage);
      } else {
        _status = RfidScanStatus.scanned;
      }
    } on RfidScanException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - RfidScan error: ${e.toString()}');
    } on NetworkException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Network error in RFID scan: ${e.toString()}');
    } on DatabaseException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Database error in RFID scan: ${e.toString()}');
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage =
          "เกิดข้อผิดพลาดที่ไม่คาดคิดในการสแกน กรุณาลองใหม่อีกครั้ง";
      print('DEBUG - Unexpected error in RFID scan: $e');
    }

    notifyListeners();
  }

  /// รีเซ็ตสถานะการสแกน
  void resetScan() {
    _status = RfidScanStatus.initial;
    _scanResults = [];
    _errorMessage = '';
    _bulkUpdateResult = null;
    notifyListeners();
  }

  // =================== Card Status Update Operations ===================

  /// อัปเดต card เดียว โดยใช้ tagId
  void updateCardStatus(String tagId, String newStatus) {
    updateMultipleCardStatus([tagId], newStatus);
  }

  /// อัปเดตหลาย cards พร้อมกัน
  void updateMultipleCardStatus(List<String> tagIds, String newStatus) {
    print('DEBUG - Updating ${tagIds.length} cards to status: $newStatus');

    int updatedCount = 0;

    for (int i = 0; i < _scanResults.length; i++) {
      final result = _scanResults[i];

      if (result.asset != null && tagIds.contains(result.asset!.tagId)) {
        // สร้าง Asset ใหม่ด้วยสถานะใหม่
        final updatedAsset = AssetModel(
          id: result.asset!.id,
          tagId: result.asset!.tagId,
          epc: result.asset!.epc,
          itemId: result.asset!.itemId,
          itemName: result.asset!.itemName,
          category: result.asset!.category,
          status: newStatus, // เปลี่ยนสถานะ
          tagType: result.asset!.tagType,
          saleDate: result.asset!.saleDate,
          frequency: result.asset!.frequency,
          currentLocation: result.asset!.currentLocation,
          zone: result.asset!.zone,
          lastScanTime: DateTime.now().toIso8601String(),
          lastScannedBy: 'User',
          batteryLevel: result.asset!.batteryLevel,
          batchNumber: result.asset!.batchNumber,
          manufacturingDate: result.asset!.manufacturingDate,
          expiryDate: result.asset!.expiryDate,
          value: result.asset!.value,
        );

        // แทนที่ด้วย EpcScanResult ใหม่
        _scanResults[i] = EpcScanResult.success(result.epc!, updatedAsset);
        updatedCount++;

        print('DEBUG - Updated card ${result.asset!.tagId} at index $i');
      }
    }

    print('DEBUG - Successfully updated $updatedCount/${tagIds.length} cards');
    notifyListeners();
  }

  /// อัปเดต Unknown EPC เป็น Asset Card (สำหรับ Asset Creation)
  void updateUnknownEpcToAsset(String epc, Asset newAsset) {
    print('DEBUG - Converting Unknown EPC to Asset: $epc');

    for (int i = 0; i < _scanResults.length; i++) {
      final result = _scanResults[i];
      if (result.epc == epc && result.asset == null) {
        // แทนที่ Unknown EPC ด้วย Asset Card
        _scanResults[i] = EpcScanResult.success(epc, newAsset);
        print('DEBUG - Converted Unknown EPC to Asset at index $i');
        break;
      }
    }

    notifyListeners();
  }

  // =================== Bulk Update Operations ===================

  /// ดำเนินการ Bulk Update Assets
  Future<void> bulkUpdateSelectedAssets(
    List<String> selectedTagIds, {
    String? lastScannedBy,
  }) async {
    try {
      _status = RfidScanStatus.bulkUpdating;
      _errorMessage = '';
      notifyListeners();

      print('DEBUG - Starting bulk update for ${selectedTagIds.length} assets');

      final result = await _bulkUpdateAssetsUseCase.execute(
        selectedTagIds,
        lastScannedBy: lastScannedBy ?? 'User',
      );

      if (result.success) {
        _bulkUpdateResult = result;
        _status = RfidScanStatus.bulkUpdateComplete;

        print(
          'DEBUG - Bulk update API successful: ${result.successCount}/${result.totalRequested}',
        );

        notifyListeners();

        // รอ 2 วินาที แล้วอัปเดต UI cards
        await Future.delayed(const Duration(seconds: 2));

        // อัปเดต scan results ด้วยสถานะใหม่
        updateMultipleCardStatus(selectedTagIds, 'Checked');

        // เปลี่ยนสถานะกลับเป็น scanned
        _status = RfidScanStatus.scanned;
        notifyListeners();
      } else {
        _status = RfidScanStatus.error;
        _errorMessage = result.errorMessage ?? 'Bulk update failed';
        notifyListeners();
      }
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = 'Error during bulk update: $e';
      print('DEBUG - Error in bulk update: $e');
      notifyListeners();
    }
  }

  /// กลับไปแสดงผลการสแกน (ใช้เมื่อผู้ใช้กดปุ่มกลับจากหน้า success)
  void returnToScanResults() {
    _status = RfidScanStatus.scanned;
    notifyListeners();
  }

  // =================== Helper Methods for UI ===================

  /// ตรวจสอบว่ามี scan results หรือไม่
  bool get hasScanResults => _scanResults.isNotEmpty;

  /// ตรวจสอบว่ามี assets ที่สามารถ bulk update ได้หรือไม่
  bool get hasUpdatableAssets {
    return _scanResults.any(
      (result) => result.asset != null && result.asset!.status == 'Available',
    );
  }

  /// ดึงรายการ assets ที่สามารถ bulk update ได้
  List<Asset> get updatableAssets {
    return _scanResults
        .where(
          (result) =>
              result.asset != null && result.asset!.status == 'Available',
        )
        .map((result) => result.asset!)
        .toList();
  }

  /// ดึงรายการ Available Assets สำหรับ Bulk Check
  List<Asset> get availableAssets {
    return _scanResults
        .where(
          (result) =>
              result.asset != null && result.asset!.status == 'Available',
        )
        .map((result) => result.asset!)
        .toList();
  }

  /// ตรวจสอบว่ามี Available Assets หรือไม่
  bool get hasAvailableAssets => availableAssets.isNotEmpty;

  /// ดึงรายการ Unknown EPCs
  List<String> get unknownEpcs {
    return _scanResults
        .where((result) => result.asset == null && result.epc != null)
        .map((result) => result.epc!)
        .toList();
  }

  /// นับจำนวน assets ตามสถานะ
  Map<String, int> get assetCountByStatus {
    Map<String, int> counts = {};

    for (final result in _scanResults) {
      if (result.asset != null) {
        final status = result.asset!.status;
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    counts['Unknown'] = unknownEpcs.length;
    return counts;
  }

  // =================== State Validation ===================

  /// ตรวจสอบความถูกต้องของสถานะก่อนดำเนินการ
  bool _validateStateForOperation(String operation) {
    switch (operation) {
      case 'scan':
        return _status == RfidScanStatus.initial ||
            _status == RfidScanStatus.error;
      case 'bulkUpdate':
        return _status == RfidScanStatus.scanned && hasUpdatableAssets;
      case 'reset':
        return true; // สามารถ reset ได้เสมอ
      default:
        return false;
    }
  }

  // =================== Public Interface Methods ===================

  /// ตรวจสอบว่าสามารถทำการสแกนได้หรือไม่
  bool canPerformScan() => _validateStateForOperation('scan');

  /// ตรวจสอบว่าสามารถทำ bulk update ได้หรือไม่
  bool canPerformBulkUpdate() => _validateStateForOperation('bulkUpdate');

  /// ล้างข้อความ error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// รีเฟรชข้อมูลโดยไม่เปลี่ยนสถานะ (สำหรับกรณีพิเศษ)
  Future<void> refreshScanResults(BuildContext context) async {
    final previousStatus = _status;
    await performScan(context);
    // คืนสถานะเดิมหากไม่มี error
    if (_status != RfidScanStatus.error) {
      _status = previousStatus;
      notifyListeners();
    }
  }

  // =================== Debug Methods ===================

  /// แสดงข้อมูล debug สำหรับการพัฒนา
  void printDebugInfo() {
    print('=== RfidScanProvider Debug Info ===');
    print('Status: $_status');
    print('Scan Results Count: ${_scanResults.length}');
    print('Asset Count by Status: $assetCountByStatus');
    print('Has Available Assets: $hasAvailableAssets');
    print('Has Updatable Assets: $hasUpdatableAssets');
    print('Unknown EPCs: ${unknownEpcs.length}');
    if (_errorMessage.isNotEmpty) {
      print('Error Message: $_errorMessage');
    }
    if (_bulkUpdateResult != null) {
      print('Bulk Update Result: ${_bulkUpdateResult!.summaryMessage}');
    }
    print('===============================');
  }
}
