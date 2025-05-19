// lib/presentation/features/dashboard/blocs/dashboard_bloc.dart
import 'package:flutter/material.dart';
import '../../../../domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;

  DashboardStatus _status = DashboardStatus.initial;
  List<Asset> _assets = [];
  List<Asset> _latestAssets = []; // เพิ่มสำหรับเก็บสินทรัพย์ล่าสุด
  int _totalAssets = 0;
  int _checkedInAssets = 0;
  int _availableAssets = 0;
  int _rfidScansToday = 0;
  String _errorMessage = '';

  DashboardBloc(this._getAssetsUseCase);

  DashboardStatus get status => _status;
  List<Asset> get assets => _assets;
  List<Asset> get latestAssets => _latestAssets;
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
      _assets = assets;
      _totalAssets = assets.length;
      _checkedInAssets = assets.where((a) => a.status == 'Checked In').length;
      _availableAssets = assets.where((a) => a.status == 'Available').length;
      _rfidScansToday = 0; // To be implemented with RFID scan logs

      // เรียงลำดับและเตรียมข้อมูลล่าสุด
      _prepareLatestAssets();

      _status = DashboardStatus.loaded;
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // เตรียมข้อมูลสินทรัพย์ล่าสุด 5 รายการ
  void _prepareLatestAssets() {
    final List<Asset> sortedAssets = List<Asset>.from(_assets);

    // เรียงตามวันที่ล่าสุด
    sortedAssets.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.lastScanTime);
        final dateB = DateTime.parse(b.lastScanTime);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    // เก็บเฉพาะ 5 รายการแรก
    _latestAssets = sortedAssets.take(5).toList();
  }

  // เพิ่มเมธอดสำหรับการนำทางไปยังรายละเอียดสินทรัพย์
  void navigateToAssetDetails(BuildContext context, Asset asset) {
    Navigator.pushNamed(
      context,
      '/assetDetail',
      arguments: {'tagId': asset.tagId},
    );
  }

  // เพิ่มเมธอดสำหรับการนำทางไปยังหน้าค้นหา
  void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, '/searchAssets');
  }

  // เช็คว่ามีข้อมูลพร้อมแสดงหรือไม่
  bool get hasData => _latestAssets.isNotEmpty;
}
