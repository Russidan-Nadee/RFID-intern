import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:rfid_project/domain/usecases/export/prepare_export_columns_usecase.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/entities/export_column.dart';
import '../../../../domain/entities/export_configuration.dart';
import '../../../../domain/repositories/asset_repository.dart';

enum ExportStatus { initial, loading, loaded, exporting, exportComplete, error }

class ExportBloc extends ChangeNotifier {
  // =================== Dependencies ===================
  final GetAssetsUseCase _getAssetsUseCase;
  final AssetRepository _assetRepository;

  // =================== Core State Variables ===================
  ExportStatus _status = ExportStatus.initial;
  ExportConfiguration _exportConfig;
  String _errorMessage = '';
  String? _lastExportedFilePath;

  // =================== Asset Data ===================
  List<Asset> _allAssets = [];
  List<Asset> _previewAssets = [];
  List<Asset> _selectedAssets = [];

  // =================== Export History ===================
  List<Map<String, dynamic>> _exportHistory = [];

  // =================== Search/Navigation Data ===================
  Map<String, dynamic>? _searchParams;
  bool _isFromSearch = false;
  String? _assetId;
  String? _assettagId;

  // =================== Multi-Select State ===================
  bool _isMultiSelectMode = false;
  Set<String> _selectedAssetIds = {};

  // =================== Constructor ===================
  ExportBloc(this._getAssetsUseCase, this._assetRepository)
    : _exportConfig = ExportConfiguration(
        columns: PrepareExportColumnsUseCase().execute(),
      ) {
    _initExportHistory();
  }

  // =================== Basic Getters ===================
  ExportStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get lastExportedFilePath => _lastExportedFilePath;
  ExportConfiguration get exportConfig => _exportConfig;

  // =================== Asset Getters ===================
  List<Asset> get allAssets => _allAssets;
  List<Asset> get previewAssets => _previewAssets;
  List<Asset> get selectedAssets => _selectedAssets;

  // =================== Export Configuration Getters ===================
  String get selectedFormat => _exportConfig.format;
  List<ExportColumn> get availableColumns => _exportConfig.columns;
  List<ExportColumn> get selectedColumns => _exportConfig.selectedColumns;
  int get estimatedFileSize =>
      _exportConfig.calculateEstimatedSize(_selectedAssets.length);

  // =================== History & Search Getters ===================
  List<Map<String, dynamic>> get exportHistory => _exportHistory;
  bool get isFromSearch => _isFromSearch;
  Map<String, dynamic>? get searchParams => _searchParams;
  String? get assetId => _assetId;
  String? get assettagId => _assettagId;

  // =================== Multi-Select Getters ===================
  bool get isMultiSelectMode => _isMultiSelectMode;
  Set<String> get selectedAssetIds => _selectedAssetIds;
  int get selectedCount => _selectedAssetIds.length;

  // =================== Column Groups ===================
  Map<String, List<ExportColumn>> get columnGroups {
    Map<String, List<ExportColumn>> groups = {};

    for (var column in _exportConfig.columns) {
      if (!groups.containsKey(column.group)) {
        groups[column.group] = [];
      }
      groups[column.group]!.add(column);
    }

    return groups;
  }

  // =================== Initialization ===================
  void _initExportHistory() {
    _exportHistory = [
      {
        'date': '2025-04-28 10:30',
        'format': 'CSV',
        'records': 42,
        'filename': 'assets_export_20250428.csv',
      },
    ];
  }

  // =================== Multi-Select Methods ===================
  void toggleMultiSelectMode() {
    _isMultiSelectMode = !_isMultiSelectMode;

    if (!_isMultiSelectMode) {
      _selectedAssetIds.clear();
    }

    notifyListeners();
  }

  void toggleAssetSelectionById(String assetId) {
    if (_selectedAssetIds.contains(assetId)) {
      _selectedAssetIds.remove(assetId);
    } else {
      _selectedAssetIds.add(assetId);
    }
    notifyListeners();
  }

  void selectAllAssetIds() {
    _selectedAssetIds.clear();
    for (var asset in _allAssets) {
      _selectedAssetIds.add(asset.id);
    }
    notifyListeners();
  }

  void clearAssetSelection() {
    _selectedAssetIds.clear();
    notifyListeners();
  }

  bool isAssetSelectedById(String assetId) {
    return _selectedAssetIds.contains(assetId);
  }

  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedAssetIds.clear();
    notifyListeners();
  }

  // =================== Arguments Processing ===================
  void setArguments(Map<String, dynamic>? args) {
    if (args == null) {
      loadAllAssets();
      return;
    }

    print('DEBUG - ExportBloc setArguments: $args');

    // Multi-Select Export
    if (args.containsKey('assets') && args.containsKey('isMultiExport')) {
      _handleMultiSelectExport(args);
      return;
    }

    // Single Asset Export
    if (args.containsKey('assetId') && args.containsKey('assetUid')) {
      _handleSingleAssetExport(args);
      return;
    }

    // Search Results Export
    if (args.containsKey('searchParams')) {
      _handleSearchResultsExport(args);
      return;
    }

    // Default: Load all assets
    print('DEBUG - Loading all assets (default case)');
    loadAllAssets();
  }

  void _handleMultiSelectExport(Map<String, dynamic> args) {
    try {
      final List<Asset> assets = args['assets'] as List<Asset>;

      print('DEBUG - Multi-export with ${assets.length} assets');

      _status = ExportStatus.loading;
      notifyListeners();

      _selectedAssets = List<Asset>.from(assets);
      _previewAssets = _selectedAssets.take(5).toList();

      loadAllAssets().then((_) {
        _status = ExportStatus.loaded;
        notifyListeners();
        print(
          'DEBUG - Multi-export setup complete: ${_selectedAssets.length} assets selected',
        );
      });
    } catch (e) {
      print('DEBUG - Error in multi-export setup: $e');
      _status = ExportStatus.error;
      _errorMessage = 'เกิดข้อผิดพลาดในการโหลดรายการที่เลือก: $e';
      notifyListeners();
    }
  }

  void _handleSingleAssetExport(Map<String, dynamic> args) {
    try {
      _assetId = args['assetId'] as String?;
      _assettagId = args['assetUid'] as String?;

      print(
        'DEBUG - Single asset export: assetId=$_assetId, tagId=$_assettagId',
      );

      if (_assettagId != null) {
        _loadSingleAsset(clearExisting: false);
      } else {
        throw Exception('ไม่พบ Tag ID ของรายการที่เลือก');
      }
    } catch (e) {
      print('DEBUG - Error in single asset setup: $e');
      _status = ExportStatus.error;
      _errorMessage = 'เกิดข้อผิดพลาดในการโหลดรายการเดียว: $e';
      notifyListeners();
    }
  }

  void _handleSearchResultsExport(Map<String, dynamic> args) {
    try {
      _isFromSearch = true;
      _searchParams = args['searchParams'] as Map<String, dynamic>?;

      print('DEBUG - Search results export: $_searchParams');

      _loadSearchResults(clearExisting: false);
    } catch (e) {
      print('DEBUG - Error in search results setup: $e');
      _status = ExportStatus.error;
      _errorMessage = 'เกิดข้อผิดพลาดในการโหลดผลการค้นหา: $e';
      notifyListeners();
    }
  }

  // =================== Data Loading Methods ===================
  Future<void> loadAllAssets() async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _allAssets = List<Asset>.from(assets);

      if (_selectedAssets.isEmpty) {
        _previewAssets = assets.take(5).toList();
      } else {
        _previewAssets = _selectedAssets.take(5).toList();
      }

      _status = ExportStatus.loaded;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> _loadSingleAsset({bool clearExisting = true}) async {
    if (_assettagId == null) return;

    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final asset = await _assetRepository.findAssetBytagId(_assettagId!);

      if (asset != null) {
        if (clearExisting) {
          _selectedAssets = [asset];
        } else {
          if (!_selectedAssets.any((a) => a.tagId == asset.tagId)) {
            _selectedAssets.add(asset);
          }
        }

        _previewAssets = List<Asset>.from(_selectedAssets).take(5).toList();
        await loadAllAssets();
        _status = ExportStatus.loaded;
      } else {
        _status = ExportStatus.error;
        _errorMessage = 'ไม่พบสินทรัพย์ที่มี tagId: $_assettagId';
      }
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> _loadSearchResults({bool clearExisting = true}) async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final allAssets = await _getAssetsUseCase.execute();
      _allAssets = allAssets;

      List<Asset> searchResults = _processSearchResults(allAssets);

      if (clearExisting) {
        _selectedAssets = List<Asset>.from(searchResults);
      } else {
        for (var asset in searchResults) {
          if (!_selectedAssets.any((a) => a.tagId == asset.tagId)) {
            _selectedAssets.add(asset);
          }
        }
      }

      _previewAssets = _selectedAssets.take(5).toList();
      _status = ExportStatus.loaded;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  List<Asset> _processSearchResults(List<Asset> allAssets) {
    if (_searchParams == null) return List<Asset>.from(allAssets);

    // Filter by status
    if (_searchParams!.containsKey('status')) {
      return allAssets
          .where((asset) => asset.status == _searchParams!['status'])
          .toList();
    }

    // Filter by query
    if (_searchParams!.containsKey('query') &&
        _searchParams!['query'] != null) {
      final query = _searchParams!['query'].toString().toLowerCase();
      if (query.isNotEmpty) {
        return allAssets
            .where(
              (asset) =>
                  asset.id.toLowerCase().contains(query) ||
                  asset.itemName.toLowerCase().contains(query) ||
                  asset.category.toLowerCase().contains(query) ||
                  asset.currentLocation.toLowerCase().contains(query),
            )
            .toList();
      }
    }

    return List<Asset>.from(allAssets);
  }

  // =================== Asset Management Methods ===================
  void toggleAssetSelection(Asset asset) {
    final index = _selectedAssets.indexWhere((a) => a.tagId == asset.tagId);

    if (index >= 0) {
      _selectedAssets.removeAt(index);
    } else {
      _selectedAssets.add(asset);
    }

    notifyListeners();
  }

  bool isAssetSelected(Asset asset) {
    return _selectedAssets.any((a) => a.tagId == asset.tagId);
  }

  void addAssets(List<Asset> assets) {
    for (var asset in assets) {
      if (!isAssetSelected(asset)) {
        _selectedAssets.add(asset);
      }
    }
    notifyListeners();
  }

  void removeAsset(Asset asset) {
    _selectedAssets.removeWhere((a) => a.tagId == asset.tagId);
    notifyListeners();
  }

  void clearSelectedAssets() {
    _selectedAssets.clear();
    notifyListeners();
  }

  Future<void> selectAllAssets() async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final allAssets = await _getAssetsUseCase.execute();
      _selectedAssets = List<Asset>.from(allAssets);
      _previewAssets = _selectedAssets.take(5).toList();
      _status = ExportStatus.loaded;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // =================== Column Management Methods ===================
  void setSelectedFormat(String format) {
    _exportConfig = _exportConfig.copyWith(format: format);
    notifyListeners();
  }

  void toggleColumnSelection(String columnKey) {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          if (column.key == columnKey) {
            return column.copyWith(isSelected: !column.isSelected);
          }
          return column;
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  bool isColumnSelected(String columnKey) {
    return _exportConfig.selectedColumns.any((c) => c.key == columnKey);
  }

  void selectAllColumnsInGroup(String groupName) {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          if (column.group == groupName) {
            return column.copyWith(isSelected: true);
          }
          return column;
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  void deselectAllColumnsInGroup(String groupName) {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          if (column.group == groupName) {
            return column.copyWith(isSelected: false);
          }
          return column;
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  bool areAllColumnsInGroupSelected(String groupName) {
    final groupColumns = _exportConfig.columns.where(
      (c) => c.group == groupName,
    );
    return groupColumns.every((column) => column.isSelected);
  }

  void selectAllColumns() {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          return column.copyWith(isSelected: true);
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  void deselectAllColumns() {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          return column.copyWith(isSelected: false);
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  // =================== Export Methods ===================
  Future<void> exportData() async {
    if (_exportConfig.format == 'CSV') {
      await exportToCSV();
    } else {
      _status = ExportStatus.error;
      _errorMessage = 'Excel export is not implemented yet';
      notifyListeners();
    }
  }

  Future<void> exportToCSV() async {
    if (_selectedAssets.isEmpty) {
      _errorMessage = 'กรุณาเลือกอย่างน้อย 1 รายการเพื่อส่งออก';
      notifyListeners();
      return;
    }

    if (_exportConfig.selectedColumns.isEmpty) {
      _errorMessage = 'กรุณาเลือกอย่างน้อย 1 คอลัมน์เพื่อส่งออก';
      notifyListeners();
      return;
    }

    _status = ExportStatus.exporting;
    notifyListeners();

    try {
      final csvData = _generateCSVData();
      final filePath = await _saveCSVFile(csvData);
      _updateExportHistory(filePath);

      _status = ExportStatus.exportComplete;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  List<List<dynamic>> _generateCSVData() {
    List<List<dynamic>> rows = [];

    // Add headers
    List<String> headers = [];
    for (var column in _exportConfig.selectedColumns) {
      headers.add(column.displayName);
    }
    rows.add(headers);

    // Add asset data
    for (var asset in _selectedAssets) {
      List<dynamic> row = [];
      for (var column in _exportConfig.selectedColumns) {
        var value = getAssetValueByColumnKey(asset, column.key);
        row.add(value);
      }
      rows.add(row);
    }

    return rows;
  }

  Future<String> _saveCSVFile(List<List<dynamic>> rows) async {
    String csv = const ListToCsvConverter().convert(rows);

    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';

    String filename =
        _selectedAssets.length == 1
            ? 'asset_${_selectedAssets[0].id}_export_$timestamp.csv'
            : 'assets_export_$timestamp.csv';

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsString(csv);

    _lastExportedFilePath = path;
    return path;
  }

  void _updateExportHistory(String filePath) {
    final now = DateTime.now();
    final filename = filePath.split('/').last;

    _exportHistory.insert(0, {
      'date': '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
      'format': 'CSV',
      'records': _selectedAssets.length,
      'filename': filename,
      'path': filePath,
    });
  }

  Future<void> shareExportedFile() async {
    if (_lastExportedFilePath != null) {
      try {
        final file = XFile(_lastExportedFilePath!);
        await Share.shareXFiles([file], subject: 'RFID Asset Data Export');
      } catch (e) {
        _errorMessage = 'Error sharing file: $e';
        notifyListeners();
      }
    } else {
      _errorMessage = 'No exported file available to share';
      notifyListeners();
    }
  }

  // =================== Utility Methods ===================
  dynamic getAssetValueByColumnKey(Asset asset, String columnKey) {
    switch (columnKey) {
      case 'id':
        return asset.id;
      case 'tagId':
        return asset.tagId;
      case 'epc':
        return asset.epc;
      case 'itemId':
        return asset.itemId;
      case 'itemName':
        return asset.itemName;
      case 'category':
        return asset.category;
      case 'status':
        return asset.status;
      case 'tagType':
        return asset.tagType;
      case 'saleDate':
        return asset.saleDate;
      case 'frequency':
        return asset.frequency;
      case 'currentLocation':
        return asset.currentLocation;
      case 'zone':
        return asset.zone;
      case 'lastScanTime':
        return asset.lastScanTime;
      case 'lastScannedBy':
        return asset.lastScannedBy;
      case 'batteryLevel':
        return asset.batteryLevel;
      case 'batchNumber':
        return asset.batchNumber;
      case 'manufacturingDate':
        return asset.manufacturingDate;
      case 'expiryDate':
        return asset.expiryDate;
      case 'value':
        return asset.value;
      default:
        return '';
    }
  }
}
