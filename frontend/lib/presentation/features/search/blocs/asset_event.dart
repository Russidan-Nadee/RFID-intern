// Path: frontend/lib/presentation/features/search/blocs/asset_event.dart
import '../../../../domain/entities/asset.dart';

abstract class AssetEvent {}

// Event to load assets
class LoadAssetsEvent extends AssetEvent {}

// Event to set search query
class SetSearchQueryEvent extends AssetEvent {
  final String query;

  SetSearchQueryEvent({required this.query});
}

// Event to set status filter
class SetStatusFilterEvent extends AssetEvent {
  final String? status;

  SetStatusFilterEvent({required this.status});
}

// Event to toggle view mode (table/card)
class ToggleViewModeEvent extends AssetEvent {}

// Multi-select events
class ToggleMultiSelectModeEvent extends AssetEvent {}

class ToggleAssetSelectionEvent extends AssetEvent {
  final String assetId;

  ToggleAssetSelectionEvent({required this.assetId});
}

class SelectAllAssetsEvent extends AssetEvent {}

class ClearSelectionEvent extends AssetEvent {}

class ExitMultiSelectModeEvent extends AssetEvent {}

// Navigation events (will emit navigation states)
class NavigateToAssetDetailEvent extends AssetEvent {
  final Asset asset;

  NavigateToAssetDetailEvent({required this.asset});
}

class NavigateToExportEvent extends AssetEvent {
  final Asset asset;
  final bool scrollToBottom;

  NavigateToExportEvent({required this.asset, this.scrollToBottom = false});
}

class NavigateToMultiExportEvent extends AssetEvent {}

// Error handling events
class ClearErrorEvent extends AssetEvent {}
