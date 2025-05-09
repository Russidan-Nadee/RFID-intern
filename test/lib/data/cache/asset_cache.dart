import '../models/asset_model.dart';

class AssetCache {
  static final AssetCache _instance = AssetCache._internal();
  factory AssetCache() => _instance;
  AssetCache._internal();

  List<AssetModel>? _assets;
  DateTime? _lastFetched;

  bool get hasValidCache {
    if (_assets == null || _lastFetched == null) return false;

    // Consider cache valid for 5 minutes
    final difference = DateTime.now().difference(_lastFetched!);
    return difference.inMinutes < 5;
  }

  void cacheAssets(List<AssetModel> assets) {
    _assets = assets;
    _lastFetched = DateTime.now();
  }

  List<AssetModel>? getAssets() {
    if (!hasValidCache) return null;
    return _assets;
  }

  void invalidateCache() {
    _assets = null;
    _lastFetched = null;
  }

  void addAsset(AssetModel asset) {
    if (_assets != null) {
      _assets!.add(asset);
    }
  }

  void removeAsset(String uid) {
    if (_assets != null) {
      _assets!.removeWhere((asset) => asset.uid == uid);
    }
  }

  void updateAsset(AssetModel updatedAsset) {
    if (_assets != null) {
      final index = _assets!.indexWhere(
        (asset) => asset.uid == updatedAsset.uid,
      );
      if (index != -1) {
        _assets![index] = updatedAsset;
      }
    }
  }
}
