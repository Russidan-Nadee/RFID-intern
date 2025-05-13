import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';

enum AssetStatus { initial, loading, loaded, error }

class AssetBloc extends ChangeNotifier {
  final GetAssetsUseCase _getAssetsUseCase;

  AssetStatus _status = AssetStatus.initial;
  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  String _errorMessage = '';
  String _searchQuery = '';
  String? _selectedStatus;
  bool _isTableView = false; // เพิ่มการติดตามโหมดการแสดงผล

  AssetBloc(this._getAssetsUseCase);

  AssetStatus get status => _status;
  List<Asset> get assets =>
      _selectedStatus == null && _searchQuery.isEmpty
          ? _assets
          : _filteredAssets;
  List<Asset> get filteredAssets => _filteredAssets;
  String get errorMessage => _errorMessage;
  String? get selectedStatus => _selectedStatus;
  bool get isTableView => _isTableView; // getter สำหรับโหมดการแสดงผล

  Future<void> loadAssets() async {
    _status = AssetStatus.loading;
    notifyListeners();

    try {
      final assets = await _getAssetsUseCase.execute();
      _assets = assets;
      _applyFilters();
      _status = AssetStatus.loaded;
    } catch (e) {
      _status = AssetStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    // เลือกค่า null หรือค่าเดิมอีกครั้ง ให้ยกเลิกฟิลเตอร์
    if (status == _selectedStatus) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    _applyFilters();
    notifyListeners();
  }

  // เพิ่มเมธอดสำหรับการสลับโหมดการแสดงผล
  void toggleViewMode() {
    _isTableView = !_isTableView;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredAssets = List.from(_assets);

    // กรองตามสถานะ
    if (_selectedStatus != null) {
      _filteredAssets =
          _filteredAssets
              .where((asset) => asset.status == _selectedStatus)
              .toList();
    }

    // กรองตามคำค้นหา
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredAssets =
          _filteredAssets.where((asset) {
            return asset.id.toLowerCase().contains(query) ||
                asset.category.toLowerCase().contains(query) ||
                asset.status.toLowerCase().contains(query) ||
                asset.brand.toLowerCase().contains(query);
          }).toList();
    }
  }

  // เพิ่มเมธอดสำหรับดึงรายการสถานะทั้งหมดที่มีในข้อมูล
  List<String> getAllStatuses() {
    final statuses = _assets.map((asset) => asset.status).toSet().toList();
    statuses.sort(); // เรียงตามตัวอักษร
    return statuses;
  }
}
