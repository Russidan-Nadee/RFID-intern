// Path: frontend/lib/presentation/features/search/blocs/asset_state.dart
import '../../../../domain/entities/asset.dart';

abstract class AssetState {
  final List<Asset> assets;
  final List<Asset> filteredAssets;
  final String errorMessage;
  final String searchQuery;
  final String? selectedStatus;
  final bool isTableView;
  final bool isMultiSelectMode;
  final Set<String> selectedAssetIds;

  const AssetState({
    this.assets = const [],
    this.filteredAssets = const [],
    this.errorMessage = '',
    this.searchQuery = '',
    this.selectedStatus,
    this.isTableView = false,
    this.isMultiSelectMode = false,
    this.selectedAssetIds = const {},
  });

  // Computed properties
  int get selectedCount => selectedAssetIds.length;

  List<String> getAllStatuses() {
    final statuses = assets.map((asset) => asset.status).toSet().toList();
    statuses.sort();
    return statuses;
  }
}

// Initial state
class AssetInitial extends AssetState {
  const AssetInitial() : super();
}

// Loading state
class AssetLoading extends AssetState {
  const AssetLoading({
    List<Asset> assets = const [],
    List<Asset> filteredAssets = const [],
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Loaded state (success)
class AssetLoaded extends AssetState {
  const AssetLoaded({
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Error state
class AssetError extends AssetState {
  const AssetError({
    required String errorMessage,
    List<Asset> assets = const [],
    List<Asset> filteredAssets = const [],
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         errorMessage: errorMessage,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Navigation states (for BlocListener)
abstract class AssetNavigationState extends AssetState {
  const AssetNavigationState({
    List<Asset> assets = const [],
    List<Asset> filteredAssets = const [],
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Navigate to asset detail
class NavigateToAssetDetail extends AssetNavigationState {
  final Asset asset;

  const NavigateToAssetDetail({
    required this.asset,
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Navigate to single asset export
class NavigateToExport extends AssetNavigationState {
  final Asset asset;
  final bool scrollToBottom;

  const NavigateToExport({
    required this.asset,
    this.scrollToBottom = false,
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Navigate to multi-select export
class NavigateToMultiExport extends AssetNavigationState {
  final List<Asset> selectedAssets;

  const NavigateToMultiExport({
    required this.selectedAssets,
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Show error message
class ShowAssetErrorMessage extends AssetNavigationState {
  const ShowAssetErrorMessage({
    required String errorMessage,
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}

// Show success message
class ShowAssetSuccessMessage extends AssetNavigationState {
  final String message;

  const ShowAssetSuccessMessage({
    required this.message,
    required List<Asset> assets,
    required List<Asset> filteredAssets,
    String searchQuery = '',
    String? selectedStatus,
    bool isTableView = false,
    bool isMultiSelectMode = false,
    Set<String> selectedAssetIds = const {},
  }) : super(
         assets: assets,
         filteredAssets: filteredAssets,
         searchQuery: searchQuery,
         selectedStatus: selectedStatus,
         isTableView: isTableView,
         isMultiSelectMode: isMultiSelectMode,
         selectedAssetIds: selectedAssetIds,
       );
}
