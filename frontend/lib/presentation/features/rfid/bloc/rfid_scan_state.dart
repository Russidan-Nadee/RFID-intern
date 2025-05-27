// Path: frontend/lib/presentation/features/rfid/blocs/rfid_scan_state.dart
import '../../../../domain/entities/epc_scan_result.dart';
import '../../../../domain/entities/asset.dart';

abstract class RfidScanState {
  final List<EpcScanResult> scanResults;
  final String errorMessage;

  const RfidScanState({this.scanResults = const [], this.errorMessage = ''});

  // Computed properties from original bloc
  bool get hasScanResults => scanResults.isNotEmpty;

  List<String> get unknownEpcs {
    return scanResults
        .where((result) => result.asset == null && result.epc != null)
        .map((result) => result.epc!)
        .toList();
  }

  Map<String, int> get assetCountByStatus {
    Map<String, int> counts = {};

    for (final result in scanResults) {
      if (result.asset != null) {
        final status = result.asset!.status;
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    counts['Unknown'] = unknownEpcs.length;
    return counts;
  }
}

// Initial state
class RfidScanInitial extends RfidScanState {
  const RfidScanInitial() : super();
}

// Scanning state
class RfidScanScanning extends RfidScanState {
  const RfidScanScanning() : super();
}

// Scanned state (success)
class RfidScanScanned extends RfidScanState {
  const RfidScanScanned({required List<EpcScanResult> scanResults})
    : super(scanResults: scanResults);
}

// Error state
class RfidScanError extends RfidScanState {
  const RfidScanError({
    required String errorMessage,
    List<EpcScanResult> scanResults = const [],
  }) : super(errorMessage: errorMessage, scanResults: scanResults);
}

// Navigation events (for BlocListener)
abstract class RfidScanNavigationState extends RfidScanState {
  const RfidScanNavigationState({
    List<EpcScanResult> scanResults = const [],
    String errorMessage = '',
  }) : super(scanResults: scanResults, errorMessage: errorMessage);
}

// Navigate to asset detail
class NavigateToAssetDetail extends RfidScanNavigationState {
  final Asset asset;

  const NavigateToAssetDetail({
    required this.asset,
    List<EpcScanResult> scanResults = const [],
  }) : super(scanResults: scanResults);
}

// Navigate to asset creation
class NavigateToAssetCreation extends RfidScanNavigationState {
  final String epc;

  const NavigateToAssetCreation({
    required this.epc,
    List<EpcScanResult> scanResults = const [],
  }) : super(scanResults: scanResults);
}

// Show error message
class ShowErrorMessage extends RfidScanNavigationState {
  const ShowErrorMessage({
    required String errorMessage,
    List<EpcScanResult> scanResults = const [],
  }) : super(errorMessage: errorMessage, scanResults: scanResults);
}

// Show success message
class ShowSuccessMessage extends RfidScanNavigationState {
  final String message;

  const ShowSuccessMessage({
    required this.message,
    List<EpcScanResult> scanResults = const [],
  }) : super(scanResults: scanResults);
}
