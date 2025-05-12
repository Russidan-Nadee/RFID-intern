import 'package:flutter/material.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;

  DashboardStatus _status = DashboardStatus.initial;
  int _totalAssets = 0;
  int _checkedInAssets = 0;
  int _availableAssets = 0;
  int _rfidScansToday = 0;
  String _errorMessage = '';

  DashboardBloc(this._getAssetsUseCase);

  DashboardStatus get status => _status;
  int get totalAssets => _totalAssets;
  int get checkedInAssets => _checkedInAssets;
  int get availableAssets => _availableAssets;
  int get rfidScansToday => _rfidScansToday;
  String get errorMessage => _errorMessage;

  Future<void> loadDashboardData() async {
    _status = DashboardStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _totalAssets = assets.length;
      _checkedInAssets = assets.where((a) => a.status == 'Checked In').length;
      _availableAssets = assets.where((a) => a.status == 'Available').length;
      _rfidScansToday = 0; // To be implemented with RFID scan logs
      _status = DashboardStatus.loaded;
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}
