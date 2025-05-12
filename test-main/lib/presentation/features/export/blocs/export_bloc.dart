import 'package:flutter/material.dart';
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

  Future<void> exportData() async {
    _status = ExportStatus.exporting;
    notifyListeners();

    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      // Add to export history
      final now = DateTime.now();
      final timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final filename =
          'assets_export_$timestamp.${_selectedFormat.toLowerCase()}';

      _exportHistory.insert(0, {
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'format': _selectedFormat,
        'records': _assets.length,
        'filename': filename,
      });

      _status = ExportStatus.exportComplete;
    } catch (e) {
      _status = ExportStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}
