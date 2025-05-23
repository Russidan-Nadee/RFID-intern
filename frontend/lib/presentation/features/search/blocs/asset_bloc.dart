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
  bool _isTableView = false; // เพิ่มการติดตามโหมดการแสดงผลง

  // =================== Multi-Select State ===================
  bool _isMultiSelectMode = false;
  Set<String> _selectedAssetIds = {};

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

  // =================== Multi-Select Getters ===================
  bool get isMultiSelectMode => _isMultiSelectMode;
  Set<String> get selectedAssetIds => _selectedAssetIds;
  int get selectedCount => _selectedAssetIds.length;

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

  // =================== Multi-Select Methods ===================
  void toggleMultiSelectMode() {
    _isMultiSelectMode = !_isMultiSelectMode;

    if (!_isMultiSelectMode) {
      _selectedAssetIds.clear();
    }

    notifyListeners();
  }

  void toggleAssetSelection(String assetId) {
    if (_selectedAssetIds.contains(assetId)) {
      _selectedAssetIds.remove(assetId);
    } else {
      _selectedAssetIds.add(assetId);
    }
    notifyListeners();
  }

  void selectAllAssets() {
    _selectedAssetIds.clear();
    for (var asset in _filteredAssets) {
      _selectedAssetIds.add(asset.id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedAssetIds.clear();
    notifyListeners();
  }

  bool isAssetSelected(String assetId) {
    return _selectedAssetIds.contains(assetId);
  }

  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedAssetIds.clear();
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
    _selectedStatus = null;
    _searchQuery = '';

    _applyFilters();
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

  // =================== Multi-Export Navigation ===================
  void navigateToMultiExport(BuildContext context) {
    if (_selectedAssetIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกรายการก่อนทำการ Export'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final selectedAssets =
          _filteredAssets
              .where((asset) => _selectedAssetIds.contains(asset.id))
              .toList();

      if (selectedAssets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบรายการที่เลือก กรุณาลองใหม่อีกครั้ง'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      Navigator.pushNamed(
        context,
        '/export',
        arguments: {
          'assets': selectedAssets,
          'isMultiExport': true,
          'selectedCount': selectedAssets.length,
          'fromMultiSelect': true,
          'sourceScreen': 'searchAssets',
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ส่งรายการ ${selectedAssets.length} รายการไปหน้า Export แล้ว',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการไปหน้า Export: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print('DEBUG - Error in navigateToMultiExport: $e');
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
