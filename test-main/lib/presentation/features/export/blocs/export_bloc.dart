import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/entities/export_column.dart';
import '../../../../domain/entities/export_configuration.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../domain/usecases/export/prepare_export_columns_usecase.dart';

enum ExportStatus { initial, loading, loaded, exporting, exportComplete, error }

class ExportBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;
  final AssetRepository _assetRepository;
  final PrepareExportColumnsUseCase _prepareExportColumnsUseCase;

  ExportStatus _status = ExportStatus.initial;
  List<Asset> _allAssets = [];
  List<Asset> _previewAssets = [];
  List<Asset> _selectedAssets = [];
  List<Map<String, dynamic>> _exportHistory = [];
  ExportConfiguration _exportConfig;

  String _errorMessage = '';
  String? _lastExportedFilePath;

  // ข้อมูลจากการค้นหา
  Map<String, dynamic>? _searchParams;
  bool _isFromSearch = false;

  // ข้อมูลสินทรัพย์เฉพาะ
  String? _assetId;
  String? _assetUid;

  ExportBloc(
    this._getAssetsUseCase,
    this._assetRepository,
    this._prepareExportColumnsUseCase,
  ) : _exportConfig = ExportConfiguration(
        columns: _prepareExportColumnsUseCase.execute(),
      ) {
    _initExportHistory();
  }

  // Getters
  ExportStatus get status => _status;
  List<Asset> get allAssets => _allAssets;
  List<Asset> get previewAssets => _previewAssets;
  List<Asset> get selectedAssets => _selectedAssets;
  List<Map<String, dynamic>> get exportHistory => _exportHistory;
  String get selectedFormat => _exportConfig.format;
  List<ExportColumn> get availableColumns => _exportConfig.columns;
  List<ExportColumn> get selectedColumns => _exportConfig.selectedColumns;
  String get errorMessage => _errorMessage;
  String? get lastExportedFilePath => _lastExportedFilePath;
  String? get assetId => _assetId;
  String? get assetUid => _assetUid;
  bool get isFromSearch => _isFromSearch;
  Map<String, dynamic>? get searchParams => _searchParams;
  ExportConfiguration get exportConfig => _exportConfig;

  // ขนาดไฟล์โดยประมาณ (KB)
  int get estimatedFileSize =>
      _exportConfig.calculateEstimatedSize(_selectedAssets.length);

  // กลุ่มของคอลัมน์
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

  // ตั้งค่า args จากหน้าอื่น
  void setArguments(Map<String, dynamic>? args) {
    if (args == null) return;

    // ตรวจสอบว่ามาจากหน้ารายละเอียดสินทรัพย์
    if (args.containsKey('assetId') && args.containsKey('assetUid')) {
      _assetId = args['assetId'];
      _assetUid = args['assetUid'];
      _loadSingleAsset(clearExisting: false);
    }
    // ตรวจสอบว่ามาจากหน้าค้นหา
    else if (args.containsKey('searchParams')) {
      _isFromSearch = true;
      _searchParams = args['searchParams'];
      _loadSearchResults(clearExisting: false);
    }
    // ถ้าไม่มี args พิเศษ ให้โหลดข้อมูลทั้งหมด
    else {
      loadAllAssets();
    }

    notifyListeners();
  }

  // โหลดข้อมูลสินทรัพย์เฉพาะจาก UID
  Future<void> _loadSingleAsset({bool clearExisting = true}) async {
    if (_assetUid == null) return;

    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final asset = await _assetRepository.findAssetByUid(_assetUid!);

      if (asset != null) {
        if (clearExisting) {
          _selectedAssets = [asset];
        } else {
          // เช็คว่ามีในรายการเลือกอยู่แล้วหรือไม่
          if (!_selectedAssets.any((a) => a.uid == asset.uid)) {
            _selectedAssets.add(asset);
          }
        }

        _previewAssets = List<Asset>.from(_selectedAssets).take(5).toList();
        await loadAllAssets(); // โหลดข้อมูลทั้งหมดไว้เผื่อผู้ใช้ต้องการเพิ่ม
        _status = ExportStatus.loaded;
      } else {
        _status = ExportStatus.error;
        _errorMessage = 'ไม่พบสินทรัพย์ที่มี UID: $_assetUid';
      }
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // โหลดข้อมูลจากผลการค้นหา
  Future<void> _loadSearchResults({bool clearExisting = true}) async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      // ในสถานการณ์จริง ควรใช้ repository ที่มีเมธอดสำหรับการค้นหาโดยเฉพาะ
      final allAssets = await _getAssetsUseCase.execute();
      _allAssets = allAssets;

      List<Asset> searchResults = [];

      // จำลองการกรองตาม searchParams
      if (_searchParams != null && _searchParams!.containsKey('status')) {
        searchResults =
            allAssets
                .where((asset) => asset.status == _searchParams!['status'])
                .toList();
      } else if (_searchParams != null &&
          _searchParams!.containsKey('query') &&
          _searchParams!['query'] != null) {
        final query = _searchParams!['query'].toString().toLowerCase();
        if (query.isNotEmpty) {
          searchResults =
              allAssets
                  .where(
                    (asset) =>
                        asset.id.toLowerCase().contains(query) ||
                        asset.brand.toLowerCase().contains(query) ||
                        asset.category.toLowerCase().contains(query) ||
                        asset.department.toLowerCase().contains(query),
                  )
                  .toList();
        } else {
          searchResults = List<Asset>.from(allAssets);
        }
      } else {
        searchResults = List<Asset>.from(allAssets);
      }

      if (clearExisting) {
        _selectedAssets = List<Asset>.from(searchResults);
      } else {
        // เพิ่มเฉพาะรายการที่ยังไม่มี
        for (var asset in searchResults) {
          if (!_selectedAssets.any((a) => a.uid == asset.uid)) {
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

  // โหลดข้อมูลทั้งหมด
  Future<void> loadAllAssets() async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _allAssets = List<Asset>.from(assets);

      // ถ้ายังไม่มีการเลือกรายการเฉพาะ ให้แสดงทั้งหมด
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

  // ตั้งค่ารูปแบบการส่งออก
  void setSelectedFormat(String format) {
    _exportConfig = _exportConfig.copyWith(format: format);
    notifyListeners();
  }

  // เพิ่ม/ลบสินทรัพย์จากรายการที่เลือก
  void toggleAssetSelection(Asset asset) {
    final index = _selectedAssets.indexWhere((a) => a.uid == asset.uid);

    if (index >= 0) {
      _selectedAssets.removeAt(index);
    } else {
      _selectedAssets.add(asset);
    }

    notifyListeners();
  }

  // เช็คว่าสินทรัพย์ถูกเลือกหรือไม่
  bool isAssetSelected(Asset asset) {
    return _selectedAssets.any((a) => a.uid == asset.uid);
  }

  // เพิ่มสินทรัพย์หลายรายการ
  void addAssets(List<Asset> assets) {
    for (var asset in assets) {
      if (!isAssetSelected(asset)) {
        _selectedAssets.add(asset);
      }
    }
    notifyListeners();
  }

  // ลบสินทรัพย์
  void removeAsset(Asset asset) {
    _selectedAssets.removeWhere((a) => a.uid == asset.uid);
    notifyListeners();
  }

  // ล้างรายการที่เลือก
  void clearSelectedAssets() {
    _selectedAssets.clear();
    notifyListeners();
  }

  // สลับการเลือกคอลัมน์
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

  // เช็คว่าคอลัมน์ถูกเลือกหรือไม่
  bool isColumnSelected(String columnKey) {
    return _exportConfig.selectedColumns.any((c) => c.key == columnKey);
  }

  // เลือกทุกคอลัมน์ในกลุ่ม
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

  // ยกเลิกการเลือกทุกคอลัมน์ในกลุ่ม
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

  // เช็คว่าทุกคอลัมน์ในกลุ่มถูกเลือกหรือไม่
  bool areAllColumnsInGroupSelected(String groupName) {
    final groupColumns = _exportConfig.columns.where(
      (c) => c.group == groupName,
    );
    return groupColumns.every((column) => column.isSelected);
  }

  // เลือกทุกคอลัมน์
  void selectAllColumns() {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          return column.copyWith(isSelected: true);
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  // ยกเลิกการเลือกทุกคอลัมน์
  void deselectAllColumns() {
    final updatedColumns =
        _exportConfig.columns.map((column) {
          return column.copyWith(isSelected: false);
        }).toList();

    _exportConfig = _exportConfig.copyWith(columns: updatedColumns);
    notifyListeners();
  }

  // ดึงค่าจากสินทรัพย์ตามชื่อคอลัมน์
  dynamic getAssetValueByColumnKey(Asset asset, String columnKey) {
    switch (columnKey) {
      case 'id':
        return asset.id;
      case 'category':
        return asset.category;
      case 'status':
        return asset.status;
      case 'brand':
      case 'itemName':
        return asset.brand;
      case 'uid':
      case 'tagId':
      case 'epc':
        return asset.uid;
      case 'department':
      case 'currentLocation':
        return asset.department;
      case 'date':
      case 'lastScanTime':
        return asset.date;
      // สำหรับฟิลด์อื่นๆ ที่ไม่มีใน Asset Entity ให้คืนค่าว่าง
      default:
        return '';
    }
  }

  // ส่งออกเป็น CSV
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
      // สร้างข้อมูลสำหรับ CSV
      List<List<dynamic>> rows = [];

      // เพิ่มหัวคอลัมน์
      List<String> headers = [];
      for (var column in _exportConfig.selectedColumns) {
        headers.add(column.displayName);
      }

      rows.add(headers);

      // เพิ่มข้อมูลสินทรัพย์ที่เลือก
      for (var asset in _selectedAssets) {
        List<dynamic> row = [];

        for (var column in _exportConfig.selectedColumns) {
          // ดึงค่าตามชื่อคอลัมน์
          var value = getAssetValueByColumnKey(asset, column.key);
          row.add(value);
        }

        rows.add(row);
      }

      // แปลงเป็นสตริง CSV
      String csv = const ListToCsvConverter().convert(rows);

      // สร้างชื่อไฟล์ด้วยเวลาปัจจุบัน
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';

      // ถ้ามีสินทรัพย์เฉพาะ ให้เพิ่ม ID ในชื่อไฟล์
      String filename =
          _selectedAssets.length == 1
              ? 'asset_${_selectedAssets[0].id}_export_$timestamp.csv'
              : 'assets_export_$timestamp.csv';

      // บันทึกไฟล์ในพื้นที่เก็บไฟล์ชั่วคราว
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsString(csv);

      // เก็บพาธไฟล์ล่าสุด
      _lastExportedFilePath = path;

      // บันทึกประวัติการส่งออก
      _exportHistory.insert(0, {
        'date': '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
        'format': 'CSV',
        'records': _selectedAssets.length,
        'filename': filename,
        'path': path, // เก็บพาธเพื่อใช้ในการแชร์ภายหลัง
      });

      _status = ExportStatus.exportComplete;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // แชร์ไฟล์ล่าสุดที่ส่งออก
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

  // ฟังก์ชันนี้จะถูกเรียกเมื่อต้องการส่งออกข้อมูล
  Future<void> exportData() async {
    if (_exportConfig.format == 'CSV') {
      await exportToCSV();
    } else {
      // Excel format is not implemented yet
      _status = ExportStatus.error;
      _errorMessage = 'Excel export is not implemented yet';
      notifyListeners();
    }
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
}
