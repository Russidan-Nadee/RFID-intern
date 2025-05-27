// Path: frontend/lib/presentation/features/rfid/blocs/rfid_scan_event.dart
import '../../../../domain/entities/asset.dart';

abstract class RfidScanEvent {}

// Event to start scanning
class StartScanEvent extends RfidScanEvent {}

// Event to reset scan results
class ResetScanEvent extends RfidScanEvent {}

// Event to update card status
class UpdateCardStatusEvent extends RfidScanEvent {
  final String tagId;
  final String newStatus;

  UpdateCardStatusEvent({required this.tagId, required this.newStatus});
}

// Event to update multiple card status
class UpdateMultipleCardStatusEvent extends RfidScanEvent {
  final List<String> tagIds;
  final String newStatus;

  UpdateMultipleCardStatusEvent({
    required this.tagIds,
    required this.newStatus,
  });
}

// Event to update unknown EPC to asset
class UpdateUnknownEpcToAssetEvent extends RfidScanEvent {
  final String epc;
  final Asset newAsset;

  UpdateUnknownEpcToAssetEvent({required this.epc, required this.newAsset});
}

// Event to clear error
class ClearErrorEvent extends RfidScanEvent {}

// Event to refresh scan results
class RefreshScanEvent extends RfidScanEvent {}
