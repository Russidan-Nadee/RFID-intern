import 'package:flutter/material.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/data/models/asset_model.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';

enum RfidScanStatus { initial, scanning, scanned, error }

class RfidScanBloc extends ChangeNotifier {
  final ScanRfidUseCase _scanRfidUseCase;

  RfidScanStatus _status = RfidScanStatus.initial;
  List<EpcScanResult> _scanResults = [];
  String _errorMessage = '';

  RfidScanBloc(this._scanRfidUseCase);

  RfidScanStatus get status => _status;
  List<EpcScanResult> get scanResults => _scanResults;
  String get errorMessage => _errorMessage;

  Future<void> performScan(BuildContext context) async {
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _scanRfidUseCase.execute();
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
    } on NetworkException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
    } on DatabaseException catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage =
          "เกิดข้อผิดพลาดที่ไม่คาดคิดในการสแกน กรุณาลองใหม่อีกครั้ง";
    }

    notifyListeners();
  }

  void resetScan() {
    _status = RfidScanStatus.initial;
    _scanResults = [];
    _errorMessage = '';
    notifyListeners();
  }

  void updateCardStatus(String tagId, String newStatus) {
    updateMultipleCardStatus([tagId], newStatus);
  }

  void updateMultipleCardStatus(List<String> tagIds, String newStatus) {
    for (int i = 0; i < _scanResults.length; i++) {
      final result = _scanResults[i];
      if (result.asset != null && tagIds.contains(result.asset!.tagId)) {
        final updatedAsset = AssetModel(
          id: result.asset!.id,
          tagId: result.asset!.tagId,
          epc: result.asset!.epc,
          itemId: result.asset!.itemId,
          itemName: result.asset!.itemName,
          category: result.asset!.category,
          status: newStatus,
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

        _scanResults[i] = EpcScanResult.success(result.epc!, updatedAsset);
      }
    }

    notifyListeners();
  }

  void updateUnknownEpcToAsset(String epc, Asset newAsset) {
    for (int i = 0; i < _scanResults.length; i++) {
      final result = _scanResults[i];
      if (result.epc == epc && result.asset == null) {
        _scanResults[i] = EpcScanResult.success(epc, newAsset);
        break;
      }
    }

    notifyListeners();
  }

  bool get hasScanResults => _scanResults.isNotEmpty;

  List<String> get unknownEpcs {
    return _scanResults
        .where((result) => result.asset == null && result.epc != null)
        .map((result) => result.epc!)
        .toList();
  }

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

  bool _validateStateForOperation(String operation) {
    switch (operation) {
      case 'scan':
        return _status == RfidScanStatus.initial ||
            _status == RfidScanStatus.error;
      case 'reset':
        return true;
      default:
        return false;
    }
  }

  bool canPerformScan() => _validateStateForOperation('scan');

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> refreshScanResults(BuildContext context) async {
    final previousStatus = _status;
    await performScan(context);
    if (_status != RfidScanStatus.error) {
      _status = previousStatus;
      notifyListeners();
    }
  }
}
