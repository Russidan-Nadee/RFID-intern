import 'package:flutter/material.dart';
import '../../../../domain/repositories/asset_repository.dart';

enum SettingsActionStatus { initial, loading, success, error }

class SettingsBloc extends ChangeNotifier {
  final AssetRepository _repository;

  SettingsActionStatus _status = SettingsActionStatus.initial;
  String _errorMessage = '';

  SettingsBloc(this._repository);

  SettingsActionStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> deleteAllAssets(BuildContext context) async {
    _status = SettingsActionStatus.loading;
    notifyListeners();

    try {
      await _repository.deleteAllAssets();
      _status = SettingsActionStatus.success;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All assets deleted successfully')),
      );

      Future.delayed(const Duration(seconds: 2), () {
        resetStatus();
      });
    } catch (e) {
      _status = SettingsActionStatus.error;
      _errorMessage = e.toString();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));

      Future.delayed(const Duration(seconds: 2), () {
        resetStatus();
      });
    }

    notifyListeners();
  }

  void resetStatus() {
    _status = SettingsActionStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
