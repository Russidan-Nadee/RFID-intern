import 'package:flutter/material.dart';
import '../../../../domain/repositories/asset_repository.dart';

enum SettingsActionStatus { initial, loading, success, error }

class SettingsBloc extends ChangeNotifier {
  final AssetRepository _repository;

  SettingsActionStatus _status = SettingsActionStatus.initial;
  String _errorMessage = '';

  // Form controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController uidController = TextEditingController();
  String selectedDepartment = 'it';

  SettingsBloc(this._repository);

  SettingsActionStatus get status => _status;
  String get errorMessage => _errorMessage;

  @override
  void dispose() {
    idController.dispose();
    categoryController.dispose();
    brandController.dispose();
    uidController.dispose();
    super.dispose();
  }

  void setDepartment(String department) {
    selectedDepartment = department;
    notifyListeners();
  }

  Future<void> deleteAllAssets(BuildContext context) async {
    _status = SettingsActionStatus.loading;
    notifyListeners();

    try {
      await _repository.deleteAllAssets();
      _status = SettingsActionStatus.success;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All assets deleted successfully')),
      );
    } catch (e) {
      _status = SettingsActionStatus.error;
      _errorMessage = e.toString();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
    }

    notifyListeners();
    // ไม่มีการเรียก resetStatus() หรือตั้งค่า _status กลับเป็น initial หลังจากแสดง SnackBar
  }

  Future<void> deleteAssetByUid(BuildContext context, String uid) async {
    if (uid.isEmpty) {
      _errorMessage = 'UID is required';
      notifyListeners();
      return;
    }

    _status = SettingsActionStatus.loading;
    notifyListeners();

    try {
      await _repository.deleteAsset(uid);
      _status = SettingsActionStatus.success;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asset with UID $uid deleted successfully')),
      );
    } catch (e) {
      _status = SettingsActionStatus.error;
      _errorMessage = e.toString();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
    }

    notifyListeners();
    // ไม่มีการเรียก resetStatus() หรือตั้งค่า _status กลับเป็น initial หลังจากแสดง SnackBar
  }

  Future<void> updateAssetStatus(
    BuildContext context,
    String uid,
    String status,
  ) async {
    if (uid.isEmpty) {
      _errorMessage = 'UID is required';
      notifyListeners();
      return;
    }

    _status = SettingsActionStatus.loading;
    notifyListeners();

    try {
      await _repository.updateAssetStatus(uid, status);
      _status = SettingsActionStatus.success;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asset status updated successfully')),
      );
    } catch (e) {
      _status = SettingsActionStatus.error;
      _errorMessage = e.toString();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
    }

    notifyListeners();
    // ไม่มีการเรียก resetStatus() หรือตั้งค่า _status กลับเป็น initial หลังจากแสดง SnackBar
  }

  void resetStatus() {
    _status = SettingsActionStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }

  // มีเมธอด resetStatus() แต่ไม่ได้ถูกเรียกใช้หลังจากการทำงานเสร็จ
}
