// Path: frontend/lib/presentation/features/search/blocs/asset_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import 'asset_event.dart';
import 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final GetAssetsUseCase _getAssetsUseCase;

  AssetBloc(this._getAssetsUseCase) : super(const AssetInitial()) {
    // Register event handlers
    on<LoadAssetsEvent>(_onLoadAssets);
    on<SetSearchQueryEvent>(_onSetSearchQuery);
    on<SetStatusFilterEvent>(_onSetStatusFilter);
    on<ToggleViewModeEvent>(_onToggleViewMode);
    on<ToggleMultiSelectModeEvent>(_onToggleMultiSelectMode);
    on<ToggleAssetSelectionEvent>(_onToggleAssetSelection);
    on<SelectAllAssetsEvent>(_onSelectAllAssets);
    on<ClearSelectionEvent>(_onClearSelection);
    on<ExitMultiSelectModeEvent>(_onExitMultiSelectMode);
    on<NavigateToAssetDetailEvent>(_onNavigateToAssetDetail);
    on<NavigateToExportEvent>(_onNavigateToExport);
    on<NavigateToMultiExportEvent>(_onNavigateToMultiExport);
    on<ClearErrorEvent>(_onClearError);
  }

  // Handle load assets event
  Future<void> _onLoadAssets(
    LoadAssetsEvent event,
    Emitter<AssetState> emit,
  ) async {
    emit(
      AssetLoading(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );

    try {
      final assets = await _getAssetsUseCase.execute();
      final filteredAssets = _applyFilters(
        assets,
        state.searchQuery,
        state.selectedStatus,
      );

      emit(
        AssetLoaded(
          assets: assets,
          filteredAssets: filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        AssetError(
          errorMessage: e.getUserFriendlyMessage(),
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    } on DatabaseException catch (e) {
      emit(
        AssetError(
          errorMessage: e.getUserFriendlyMessage(),
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    } on AssetNotFoundException catch (e) {
      emit(
        AssetError(
          errorMessage: e.getUserFriendlyMessage(),
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    } catch (e) {
      emit(
        AssetError(
          errorMessage: "เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง",
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    }
  }

  // Handle set search query event
  void _onSetSearchQuery(SetSearchQueryEvent event, Emitter<AssetState> emit) {
    final filteredAssets = _applyFilters(
      state.assets,
      event.query,
      state.selectedStatus,
    );

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: filteredAssets,
        searchQuery: event.query,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle set status filter event
  void _onSetStatusFilter(
    SetStatusFilterEvent event,
    Emitter<AssetState> emit,
  ) {
    // เลือกค่า null หรือค่าเดิมอีกครั้ง ให้ยกเลิกฟิลเตอร์
    final newStatus =
        (event.status == state.selectedStatus) ? null : event.status;
    final filteredAssets = _applyFilters(
      state.assets,
      state.searchQuery,
      newStatus,
    );

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: newStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle toggle view mode event
  void _onToggleViewMode(ToggleViewModeEvent event, Emitter<AssetState> emit) {
    // Reset filters when switching view mode
    final filteredAssets = _applyFilters(state.assets, '', null);

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: filteredAssets,
        searchQuery: '',
        selectedStatus: null,
        isTableView: !state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle toggle multi-select mode event
  void _onToggleMultiSelectMode(
    ToggleMultiSelectModeEvent event,
    Emitter<AssetState> emit,
  ) {
    final newMultiSelectMode = !state.isMultiSelectMode;
    final newSelectedIds =
        newMultiSelectMode ? state.selectedAssetIds : <String>{};

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: newMultiSelectMode,
        selectedAssetIds: newSelectedIds,
      ),
    );
  }

  // Handle toggle asset selection event
  void _onToggleAssetSelection(
    ToggleAssetSelectionEvent event,
    Emitter<AssetState> emit,
  ) {
    final newSelectedIds = Set<String>.from(state.selectedAssetIds);

    if (newSelectedIds.contains(event.assetId)) {
      newSelectedIds.remove(event.assetId);
    } else {
      newSelectedIds.add(event.assetId);
    }

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: newSelectedIds,
      ),
    );
  }

  // Handle select all assets event
  void _onSelectAllAssets(
    SelectAllAssetsEvent event,
    Emitter<AssetState> emit,
  ) {
    final newSelectedIds = <String>{};
    for (var asset in state.filteredAssets) {
      newSelectedIds.add(asset.id);
    }

    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: newSelectedIds,
      ),
    );
  }

  // Handle clear selection event
  void _onClearSelection(ClearSelectionEvent event, Emitter<AssetState> emit) {
    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: <String>{},
      ),
    );
  }

  // Handle exit multi-select mode event
  void _onExitMultiSelectMode(
    ExitMultiSelectModeEvent event,
    Emitter<AssetState> emit,
  ) {
    emit(
      AssetLoaded(
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: false,
        selectedAssetIds: <String>{},
      ),
    );
  }

  // Handle navigate to asset detail event
  void _onNavigateToAssetDetail(
    NavigateToAssetDetailEvent event,
    Emitter<AssetState> emit,
  ) {
    emit(
      NavigateToAssetDetail(
        asset: event.asset,
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle navigate to export event
  void _onNavigateToExport(
    NavigateToExportEvent event,
    Emitter<AssetState> emit,
  ) {
    emit(
      NavigateToExport(
        asset: event.asset,
        scrollToBottom: event.scrollToBottom,
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle navigate to multi-export event
  void _onNavigateToMultiExport(
    NavigateToMultiExportEvent event,
    Emitter<AssetState> emit,
  ) {
    if (state.selectedAssetIds.isEmpty) {
      emit(
        ShowAssetErrorMessage(
          errorMessage: 'กรุณาเลือกรายการก่อนทำการ Export',
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
      return;
    }

    final selectedAssets =
        state.filteredAssets
            .where((asset) => state.selectedAssetIds.contains(asset.id))
            .toList();

    if (selectedAssets.isEmpty) {
      emit(
        ShowAssetErrorMessage(
          errorMessage: 'ไม่พบรายการที่เลือก กรุณาลองใหม่อีกครั้ง',
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
      return;
    }

    emit(
      NavigateToMultiExport(
        selectedAssets: selectedAssets,
        assets: state.assets,
        filteredAssets: state.filteredAssets,
        searchQuery: state.searchQuery,
        selectedStatus: state.selectedStatus,
        isTableView: state.isTableView,
        isMultiSelectMode: state.isMultiSelectMode,
        selectedAssetIds: state.selectedAssetIds,
      ),
    );
  }

  // Handle clear error event
  void _onClearError(ClearErrorEvent event, Emitter<AssetState> emit) {
    if (state is AssetError) {
      emit(
        AssetLoaded(
          assets: state.assets,
          filteredAssets: state.filteredAssets,
          searchQuery: state.searchQuery,
          selectedStatus: state.selectedStatus,
          isTableView: state.isTableView,
          isMultiSelectMode: state.isMultiSelectMode,
          selectedAssetIds: state.selectedAssetIds,
        ),
      );
    }
  }

  // Helper method to apply filters
  List<Asset> _applyFilters(
    List<Asset> assets,
    String searchQuery,
    String? selectedStatus,
  ) {
    List<Asset> filtered = List.from(assets);

    // กรองตามสถานะ
    if (selectedStatus != null) {
      filtered =
          filtered.where((asset) => asset.status == selectedStatus).toList();
    }

    // กรองตามคำค้นหา
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered =
          filtered.where((asset) {
            return asset.id.toLowerCase().contains(query) ||
                asset.category.toLowerCase().contains(query) ||
                asset.status.toLowerCase().contains(query) ||
                asset.itemName.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }

  // Legacy methods for backward compatibility (now emit events)
  void loadAssets() {
    add(LoadAssetsEvent());
  }

  void setSearchQuery(String query) {
    add(SetSearchQueryEvent(query: query));
  }

  void setStatusFilter(String? status) {
    add(SetStatusFilterEvent(status: status));
  }

  void toggleViewMode() {
    add(ToggleViewModeEvent());
  }

  void toggleMultiSelectMode() {
    add(ToggleMultiSelectModeEvent());
  }

  void toggleAssetSelection(String assetId) {
    add(ToggleAssetSelectionEvent(assetId: assetId));
  }

  void selectAllAssets() {
    add(SelectAllAssetsEvent());
  }

  void clearSelection() {
    add(ClearSelectionEvent());
  }

  void exitMultiSelectMode() {
    add(ExitMultiSelectModeEvent());
  }

  void navigateToAssetDetail(Asset asset) {
    add(NavigateToAssetDetailEvent(asset: asset));
  }

  void navigateToExport(Asset asset, {bool scrollToBottom = false}) {
    add(NavigateToExportEvent(asset: asset, scrollToBottom: scrollToBottom));
  }

  void navigateToMultiExport() {
    add(NavigateToMultiExportEvent());
  }

  void clearError() {
    add(ClearErrorEvent());
  }

  // Getters for backward compatibility
  List<Asset> get assets =>
      state.selectedStatus == null && state.searchQuery.isEmpty
          ? state.assets
          : state.filteredAssets;

  List<Asset> get filteredAssets => state.filteredAssets;
  String get errorMessage => state.errorMessage;
  String? get selectedStatus => state.selectedStatus;
  bool get isTableView => state.isTableView;
  bool get isMultiSelectMode => state.isMultiSelectMode;
  Set<String> get selectedAssetIds => state.selectedAssetIds;
  int get selectedCount => state.selectedCount;

  bool isAssetSelected(String assetId) {
    return state.selectedAssetIds.contains(assetId);
  }

  List<String> getAllStatuses() {
    return state.getAllStatuses();
  }
}
