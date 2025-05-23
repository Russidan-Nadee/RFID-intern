import 'package:flutter/material.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;

  ReportsStatus _status = ReportsStatus.initial;
  List<Asset> _assets = [];
  String _errorMessage = '';
  String _selectedReportType = 'category'; // category, status, currentLocation

  ReportsBloc(this._getAssetsUseCase);

  ReportsStatus get status => _status;
  List<Asset> get assets => _assets;
  String get errorMessage => _errorMessage;
  String get selectedReportType => _selectedReportType;

  // ข้อมูลสำหรับกราฟแยกตามหมวดหมู่
  Map<String, int> get categoryStats {
    Map<String, int> result = {};
    for (var asset in _assets) {
      result[asset.category] = (result[asset.category] ?? 0) + 1;
    }
    return result;
  }

  // ข้อมูลสำหรับกราฟแยกตามสถานะ
  Map<String, int> get statusStats {
    Map<String, int> result = {};
    for (var asset in _assets) {
      result[asset.status] = (result[asset.status] ?? 0) + 1;
    }
    return result;
  }

  // ข้อมูลสำหรับกราฟแยกตามแผนก
  Map<String, int> get currentLocationStats {
    Map<String, int> result = {};
    for (var asset in _assets) {
      result[asset.currentLocation] = (result[asset.currentLocation] ?? 0) + 1;
    }
    return result;
  }

  Future<void> loadReportData() async {
    _status = ReportsStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _assets = assets;
      _status = ReportsStatus.loaded;
    } catch (e) {
      _status = ReportsStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void setReportType(String type) {
    _selectedReportType = type;
    notifyListeners();
  }
}
