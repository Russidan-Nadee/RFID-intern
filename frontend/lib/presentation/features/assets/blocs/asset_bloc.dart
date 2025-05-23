// lib/presentation/features/assets/blocs/asset_bloc.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import '../../../../domain/entities/asset.dart';
import '../../../../core/exceptions/app_exceptions.dart';

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
    } on NetworkException catch (e) {
      _status = AssetStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Network error in loadAssets: ${e.toString()}');
    } on DatabaseException catch (e) {
      _status = AssetStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Database error in loadAssets: ${e.toString()}');
    } on AssetNotFoundException catch (e) {
      _status = AssetStatus.error;
      _errorMessage = e.getUserFriendlyMessage();
      print('DEBUG - Asset not found in loadAssets: ${e.toString()}');
    } catch (e) {
      _status = AssetStatus.error;
      _errorMessage = "เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง";
      print('DEBUG - Unexpected error in loadAssets: $e');
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

  // เพิ่มฟังก์ชันสำหรับการนำทางไปดูรายละเอียดสินทรัพย์
  void navigateToAssetDetail(BuildContext context, Asset asset) {
    try {
      if (asset.tagId.isEmpty) {
        throw AssetNotFoundException("ไม่พบรหัส Tag ID สำหรับสินทรัพย์นี้");
      }

      Navigator.pushNamed(
        context,
        '/assetDetail',
        arguments: {'tagId': asset.tagId}, // แก้จาก uid เป็น tagId
      );
    } catch (e) {
      // จัดการข้อผิดพลาดใน UI
      if (e is AssetNotFoundException) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.getUserFriendlyMessage())));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการนำทาง: $e')));
      }
      print('DEBUG - Error in navigateToAssetDetail: $e');
    }
  }

  // เพิ่มฟังก์ชันสำหรับการนำทางไปส่งออกสินทรัพย์
  void navigateToExport(
    BuildContext context,
    Asset asset, {
    bool scrollToBottom = false,
  }) {
    try {
      Navigator.pushNamed(
        context,
        '/export',
        arguments: {
          'assetId': asset.id,
          'assetUid': asset.tagId, // แก้จาก uid เป็น tagId
          'scrollToBottom': scrollToBottom,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการนำทางไปยังการส่งออก: $e')),
      );
      print('DEBUG - Error in navigateToExport: $e');
    }
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
                asset.itemName.toLowerCase().contains(
                  query,
                ); // แก้จาก brand เป็น itemName
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
