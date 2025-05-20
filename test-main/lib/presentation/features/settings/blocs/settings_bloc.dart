// lib/presentation/features/settings/blocs/settings_bloc.dart
import 'package:flutter/material.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsBloc extends ChangeNotifier {
  SettingsStatus _status = SettingsStatus.initial;
  String _errorMessage = '';

  SettingsStatus get status => _status;
  String get errorMessage => _errorMessage;

  // เมธอดสำหรับรีเซ็ตสถานะ
  void resetStatus() {
    _status = SettingsStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
