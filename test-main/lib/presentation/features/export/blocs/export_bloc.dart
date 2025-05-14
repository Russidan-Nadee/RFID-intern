// lib/presentation/features/export/blocs/export_bloc.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../domain/repositories/asset_repository.dart';

enum ExportStatus { initial, loading, loaded, exporting, exportComplete, error }

class ExportBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;
  final AssetRepository _assetRepository;

  ExportStatus _status = ExportStatus.initial;
  List<Asset> _allAssets = [];
  List<Asset> _previewAssets = [];
  List<Asset> _selectedAssets = [];
  List<Map<String, dynamic>> _exportHistory = [];

  // คอลัมน์ทั้งหมดที่มีให้เลือก
  final List<String> _availableColumns = [
    'id',
    'itemId',
    'tagId',
    'epc',
    'itemName',
    'category',
    'status',
    'tagType',
    'value',
    'frequency',
    'currentLocation',
    'zone',
    'lastScanTime',
    'lastScanQuantity',
    'batteryLevel',
    'batchNumber',
    'manufacturingDate',
  ];

  // กลุ่มของคอลัมน์
  final Map<String, List<String>> _columnGroups = {
    'ข้อมูลระบุตัวตน': ['id', 'itemId', 'tagId', 'epc'],
    'ข้อมูลสินค้า': ['itemName', 'category', 'status', 'value', 'tagType'],
    'ข้อมูลตำแหน่ง': ['currentLocation', 'zone'],
    'ข้อมูลเวลาและการติดตาม': ['lastScanTime', 'lastScanQuantity'],
    'ข้อมูลเทคนิค': [
      'batteryLevel',
      'batchNumber',
      'frequency',
      'manufacturingDate',
    ],
  };

  List<String> _selectedColumns = []; // เริ่มต้นเป็น empty list

  ExportBloc(this._getAssetsUseCase, this._assetRepository) {
    _initExportHistory();
    _selectedColumns.addAll(_availableColumns); // เลือกทุกคอลัมน์เริ่มต้น
  }
  String _selectedFormat = 'CSV';
  String _errorMessage = '';
  String? _lastExportedFilePath;

  // ข้อมูลจากการค้นหา
  Map<String, dynamic>? _searchParams;
  bool _isFromSearch = false;

  // ข้อมูลสินทรัพย์เฉพาะ
  String? _assetId;
  String? _assetUid;

  // Getters
  ExportStatus get status => _status;
  List<Asset> get allAssets => _allAssets;
  List<Asset> get previewAssets => _previewAssets;
  List<Asset> get selectedAssets => _selectedAssets;
  List<Map<String, dynamic>> get exportHistory => _exportHistory;
  String get selectedFormat => _selectedFormat;
  List<String> get selectedColumns => _selectedColumns;
  List<String> get availableColumns => _availableColumns;
  Map<String, List<String>> get columnGroups => _columnGroups;
  String get errorMessage => _errorMessage;
  String? get lastExportedFilePath => _lastExportedFilePath;
  String? get assetId => _assetId;
  String? get assetUid => _assetUid;
  bool get isFromSearch => _isFromSearch;
  Map<String, dynamic>? get searchParams => _searchParams;

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
    _selectedFormat = format;
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
  void toggleColumnSelection(String column) {
    if (_selectedColumns.contains(column)) {
      _selectedColumns.remove(column);
    } else {
      _selectedColumns.add(column);
    }
    notifyListeners();
  }

  // เช็คว่าคอลัมน์ถูกเลือกหรือไม่
  bool isColumnSelected(String column) {
    return _selectedColumns.contains(column);
  }

  // เลือกทุกคอลัมน์ในกลุ่ม
  void selectAllColumnsInGroup(String groupName) {
    if (!_columnGroups.containsKey(groupName)) return;

    for (var column in _columnGroups[groupName]!) {
      if (!_selectedColumns.contains(column)) {
        _selectedColumns.add(column);
      }
    }

    notifyListeners();
  }

  // ยกเลิกการเลือกทุกคอลัมน์ในกลุ่ม
  void deselectAllColumnsInGroup(String groupName) {
    if (!_columnGroups.containsKey(groupName)) return;

    for (var column in _columnGroups[groupName]!) {
      _selectedColumns.remove(column);
    }

    notifyListeners();
  }

  // เช็คว่าทุกคอลัมน์ในกลุ่มถูกเลือกหรือไม่
  bool areAllColumnsInGroupSelected(String groupName) {
    if (!_columnGroups.containsKey(groupName)) return false;

    return _columnGroups[groupName]!.every(
      (column) => _selectedColumns.contains(column),
    );
  }

  // เลือกทุกคอลัมน์
  void selectAllColumns() {
    _selectedColumns = List<String>.from(_availableColumns);
    notifyListeners();
  }

  // ยกเลิกการเลือกทุกคอลัมน์
  void deselectAllColumns() {
    _selectedColumns.clear();
    notifyListeners();
  }

  // ค้นหาสินทรัพย์ตามฟิลเตอร์
  Future<void> searchAssets({
    String? status,
    String? location,
    String? category,
  }) async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      // ในสถานการณ์จริงควรใช้ repository ที่มีเมธอดสำหรับการค้นหาโดยเฉพาะ
      List<Asset> filteredAssets = List<Asset>.from(_allAssets);

      if (status != null && status.isNotEmpty) {
        filteredAssets =
            filteredAssets
                .where(
                  (asset) => asset.status.toLowerCase() == status.toLowerCase(),
                )
                .toList();
      }

      if (location != null && location.isNotEmpty) {
        filteredAssets =
            filteredAssets
                .where(
                  (asset) => asset.department.toLowerCase().contains(
                    location.toLowerCase(),
                  ),
                )
                .toList();
      }

      if (category != null && category.isNotEmpty) {
        filteredAssets =
            filteredAssets
                .where(
                  (asset) =>
                      asset.category.toLowerCase() == category.toLowerCase(),
                )
                .toList();
      }

      _previewAssets = filteredAssets.take(5).toList();
      _status = ExportStatus.loaded;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // ส่งออกเป็น CSV
  Future<void> exportToCSV() async {
    if (_selectedAssets.isEmpty) {
      _errorMessage = 'กรุณาเลือกอย่างน้อย 1 รายการเพื่อส่งออก';
      notifyListeners();
      return;
    }

    if (_selectedColumns.isEmpty) {
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
      for (var column in _selectedColumns) {
        // แปลงชื่อคอลัมน์เป็นชื่อที่อ่านง่าย
        String headerName = _getDisplayNameForColumn(column);
        headers.add(headerName);
      }

      rows.add(headers);

      // เพิ่มข้อมูลสินทรัพย์ที่เลือก
      for (var asset in _selectedAssets) {
        List<dynamic> row = [];

        for (var column in _selectedColumns) {
          // ดึงค่าตามชื่อคอลัมน์
          var value = _getAssetValueByColumnName(asset, column);
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

  // แปลงชื่อคอลัมน์เป็นชื่อที่อ่านง่าย
  String _getDisplayNameForColumn(String column) {
    switch (column) {
      case 'id':
        return 'ID';
      case 'itemId':
        return 'Item ID';
      case 'tagId':
        return 'Tag ID';
      case 'epc':
        return 'EPC';
      case 'itemName':
        return 'Item Name';
      case 'category':
        return 'Category';
      case 'status':
        return 'Status';
      case 'tagType':
        return 'Tag Type';
      case 'value':
        return 'Value';
      case 'frequency':
        return 'Frequency';
      case 'currentLocation':
        return 'Location';
      case 'zone':
        return 'Zone';
      case 'lastScanTime':
        return 'Last Scan Time';
      case 'lastScanQuantity':
        return 'Last Scan Quantity';
      case 'batteryLevel':
        return 'Battery Level';
      case 'batchNumber':
        return 'Batch Number';
      case 'manufacturingDate':
        return 'Manufacturing Date';
      default:
        return column;
    }
  }

  // ดึงค่าจากสินทรัพย์ตามชื่อคอลัมน์
  dynamic _getAssetValueByColumnName(Asset asset, String column) {
    switch (column) {
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
    if (_selectedFormat == 'CSV') {
      await exportToCSV();
    } else {
      // Excel format is not implemented yet
      _status = ExportStatus.error;
      _errorMessage = 'Excel export is not implemented yet';
      notifyListeners();
    }
  }
}
