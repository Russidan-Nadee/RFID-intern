import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';

enum ExportStatus { initial, loading, loaded, exporting, exportComplete, error }

class ExportBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;

  ExportStatus _status = ExportStatus.initial;
  List<Asset> _assets = [];
  List<Asset> _previewAssets = [];
  List<Map<String, dynamic>> _exportHistory = [];
  String _selectedFormat = 'CSV';
  List<String> _selectedColumns = ['ID', 'Category', 'Brand', 'Status', 'Date'];
  List<String> _selectedStatus = ['All'];
  String _errorMessage = '';
  String? _lastExportedFilePath;

  ExportBloc(this._getAssetsUseCase) {
    _initExportHistory();
  }

  ExportStatus get status => _status;
  List<Asset> get assets => _assets;
  List<Asset> get previewAssets => _previewAssets;
  List<Map<String, dynamic>> get exportHistory => _exportHistory;
  String get selectedFormat => _selectedFormat;
  List<String> get selectedColumns => _selectedColumns;
  List<String> get selectedStatus => _selectedStatus;
  String get errorMessage => _errorMessage;
  String? get lastExportedFilePath => _lastExportedFilePath;

  void _initExportHistory() {
    _exportHistory = [
      {
        'date': '2025-04-28 10:30',
        'format': 'CSV',
        'records': 42,
        'filename': 'assets_export_20250428.csv',
      },
      {
        'date': '2025-04-25 14:15',
        'format': 'Excel',
        'records': 38,
        'filename': 'assets_export_20250425.xlsx',
      },
    ];
  }

  Future<void> loadPreviewData() async {
    _status = ExportStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _assets = assets;
      _previewAssets = assets.take(5).toList();
      _status = ExportStatus.loaded;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void setSelectedFormat(String format) {
    _selectedFormat = format;
    notifyListeners();
  }

  void toggleColumnSelection(String column) {
    if (_selectedColumns.contains(column)) {
      _selectedColumns.remove(column);
    } else {
      _selectedColumns.add(column);
    }
    notifyListeners();
  }

  void selectAllColumns(bool select, List<String> availableColumns) {
    if (select) {
      _selectedColumns = List.from(availableColumns);
    } else {
      _selectedColumns = [];
    }
    notifyListeners();
  }

  void toggleStatusSelection(String status, List<String> availableStatus) {
    if (status == 'All') {
      if (_selectedStatus.contains('All')) {
        _selectedStatus.remove('All');
      } else {
        _selectedStatus = ['All'];
      }
    } else {
      if (_selectedStatus.contains(status)) {
        _selectedStatus.remove(status);
      } else {
        _selectedStatus.add(status);
        _selectedStatus.remove('All');
      }

      if (_selectedStatus.isEmpty) {
        _selectedStatus = ['All'];
      }
    }
    notifyListeners();
  }

  // ฟังก์ชันใหม่สำหรับส่งออกเป็น CSV
  Future<void> exportToCSV() async {
    _status = ExportStatus.exporting;
    notifyListeners();

    try {
      // สร้างข้อมูลสำหรับ CSV
      List<List<dynamic>> rows = [];

      // เพิ่มหัวคอลัมน์
      List<String> headers = [];
      if (_selectedColumns.contains('ID')) headers.add('ID');
      if (_selectedColumns.contains('Category')) headers.add('Category');
      if (_selectedColumns.contains('Brand')) headers.add('Brand');
      if (_selectedColumns.contains('Status')) headers.add('Status');
      if (_selectedColumns.contains('Department')) headers.add('Department');
      if (_selectedColumns.contains('Date')) headers.add('Date');
      if (_selectedColumns.contains('UID')) headers.add('UID');

      rows.add(headers);

      // เพิ่มข้อมูลสินทรัพย์
      for (var asset in _assets) {
        List<dynamic> row = [];
        if (_selectedColumns.contains('ID')) row.add(asset.id);
        if (_selectedColumns.contains('Category')) row.add(asset.category);
        if (_selectedColumns.contains('Brand')) row.add(asset.brand);
        if (_selectedColumns.contains('Status')) row.add(asset.status);
        if (_selectedColumns.contains('Department')) row.add(asset.department);
        if (_selectedColumns.contains('Date')) row.add(asset.date);
        if (_selectedColumns.contains('UID')) row.add(asset.uid);

        rows.add(row);
      }

      // แปลงเป็นสตริง CSV
      String csv = const ListToCsvConverter().convert(rows);

      // สร้างชื่อไฟล์ด้วยเวลาปัจจุบัน
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}';
      final filename = 'assets_export_$timestamp.csv';

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
        'records': _assets.length,
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

  // ฟังก์ชันใหม่สำหรับแชร์ไฟล์ล่าสุดที่ส่งออก
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
