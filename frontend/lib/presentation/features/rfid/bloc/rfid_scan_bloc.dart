// Path: frontend/lib/presentation/features/rfid/blocs/rfid_scan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rfid_project/domain/entities/epc_scan_result.dart';
import 'package:rfid_project/domain/entities/asset.dart';
import 'package:rfid_project/data/models/asset_model.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import 'rfid_scan_event.dart';
import 'rfid_scan_state.dart';

class RfidScanBloc extends Bloc<RfidScanEvent, RfidScanState> {
  final ScanRfidUseCase _scanRfidUseCase;

  RfidScanBloc(this._scanRfidUseCase) : super(const RfidScanInitial()) {
    // Register event handlers
    on<StartScanEvent>(_onStartScan);
    on<ResetScanEvent>(_onResetScan);
    on<UpdateCardStatusEvent>(_onUpdateCardStatus);
    on<UpdateMultipleCardStatusEvent>(_onUpdateMultipleCardStatus);
    on<UpdateUnknownEpcToAssetEvent>(_onUpdateUnknownEpcToAsset);
    on<ClearErrorEvent>(_onClearError);
    on<RefreshScanEvent>(_onRefreshScan);
  }

  // Handle start scan event
  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<RfidScanState> emit,
  ) async {
    emit(const RfidScanScanning());

    try {
      final results = await _scanRfidUseCase.execute();

      if (results.isEmpty) {
        emit(const RfidScanError(errorMessage: "ไม่พบผลลัพธ์การสแกน"));
      } else if (results.first.success == false) {
        emit(
          RfidScanError(
            errorMessage:
                results.first.errorMessage ?? "เกิดข้อผิดพลาดในการสแกน",
          ),
        );
      } else {
        emit(RfidScanScanned(scanResults: results));
      }
    } on RfidScanException catch (e) {
      emit(RfidScanError(errorMessage: e.getUserFriendlyMessage()));
    } on NetworkException catch (e) {
      emit(RfidScanError(errorMessage: e.getUserFriendlyMessage()));
    } on DatabaseException catch (e) {
      emit(RfidScanError(errorMessage: e.getUserFriendlyMessage()));
    } catch (e) {
      emit(
        const RfidScanError(
          errorMessage:
              "เกิดข้อผิดพลาดที่ไม่คาดคิดในการสแกน กรุณาลองใหม่อีกครั้ง",
        ),
      );
    }
  }

  // Handle reset scan event
  void _onResetScan(ResetScanEvent event, Emitter<RfidScanState> emit) {
    emit(const RfidScanInitial());
  }

  // Handle update card status event
  void _onUpdateCardStatus(
    UpdateCardStatusEvent event,
    Emitter<RfidScanState> emit,
  ) {
    _updateCardStatusInternal([event.tagId], event.newStatus, emit);
  }

  // Handle update multiple card status event
  void _onUpdateMultipleCardStatus(
    UpdateMultipleCardStatusEvent event,
    Emitter<RfidScanState> emit,
  ) {
    _updateCardStatusInternal(event.tagIds, event.newStatus, emit);
  }

  // Internal method to update card status
  void _updateCardStatusInternal(
    List<String> tagIds,
    String newStatus,
    Emitter<RfidScanState> emit,
  ) {
    final currentResults = List<EpcScanResult>.from(state.scanResults);

    for (int i = 0; i < currentResults.length; i++) {
      final result = currentResults[i];
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

        currentResults[i] = EpcScanResult.success(result.epc!, updatedAsset);
      }
    }

    emit(RfidScanScanned(scanResults: currentResults));
  }

  // Handle update unknown EPC to asset event
  void _onUpdateUnknownEpcToAsset(
    UpdateUnknownEpcToAssetEvent event,
    Emitter<RfidScanState> emit,
  ) {
    final currentResults = List<EpcScanResult>.from(state.scanResults);

    for (int i = 0; i < currentResults.length; i++) {
      final result = currentResults[i];
      if (result.epc == event.epc && result.asset == null) {
        currentResults[i] = EpcScanResult.success(event.epc, event.newAsset);
        break;
      }
    }

    emit(RfidScanScanned(scanResults: currentResults));
  }

  // Handle clear error event
  void _onClearError(ClearErrorEvent event, Emitter<RfidScanState> emit) {
    if (state is RfidScanError) {
      emit(RfidScanScanned(scanResults: state.scanResults));
    }
  }

  // Handle refresh scan event
  Future<void> _onRefreshScan(
    RefreshScanEvent event,
    Emitter<RfidScanState> emit,
  ) async {
    final previousResults = state.scanResults;
    await _onStartScan(StartScanEvent(), emit);

    // If scan failed, restore previous results but keep them visible
    if (state is RfidScanError && previousResults.isNotEmpty) {
      emit(RfidScanScanned(scanResults: previousResults));
    }
  }

  // Helper methods for backward compatibility
  bool get canPerformScan => state is RfidScanInitial || state is RfidScanError;

  // Legacy methods that now emit events
  void performScan() {
    add(StartScanEvent());
  }

  void resetScan() {
    add(ResetScanEvent());
  }

  void updateCardStatus(String tagId, String newStatus) {
    add(UpdateCardStatusEvent(tagId: tagId, newStatus: newStatus));
  }

  void updateMultipleCardStatus(List<String> tagIds, String newStatus) {
    add(UpdateMultipleCardStatusEvent(tagIds: tagIds, newStatus: newStatus));
  }

  void updateUnknownEpcToAsset(String epc, Asset newAsset) {
    add(UpdateUnknownEpcToAssetEvent(epc: epc, newAsset: newAsset));
  }

  void clearError() {
    add(ClearErrorEvent());
  }

  void refreshScanResults() {
    add(RefreshScanEvent());
  }

  // Getters for backward compatibility
  bool get hasScanResults => state.hasScanResults;
  List<String> get unknownEpcs => state.unknownEpcs;
  Map<String, int> get assetCountByStatus => state.assetCountByStatus;
  List<EpcScanResult> get scanResults => state.scanResults;
  String get errorMessage => state.errorMessage;
}
