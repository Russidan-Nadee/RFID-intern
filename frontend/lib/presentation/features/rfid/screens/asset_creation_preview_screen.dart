import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rfid_project/domain/service/auth_service.dart';
import 'package:rfid_project/data/models/asset_model.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../core/constants/app_constants.dart';

class AssetCreationFormScreen extends StatefulWidget {
  final String epc;
  final AssetRepository assetRepository;

  const AssetCreationFormScreen({
    Key? key,
    required this.epc,
    required this.assetRepository,
  }) : super(key: key);

  @override
  State<AssetCreationFormScreen> createState() =>
      _AssetCreationFormScreenState();
}

class _AssetCreationFormScreenState extends State<AssetCreationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;
  String? _errorMessage;
  bool _isSuccess = false;
  bool _isLoadingData = true;

  // Controllers
  final _itemNameController = TextEditingController();
  final _valueController = TextEditingController();
  final _batchNumberController = TextEditingController();

  // Dropdown values
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedTagType;
  String? _selectedStatus;

  // Dropdown options
  List<String> _categories = [];
  List<String> _locations = [];
  final List<String> _tagTypes = ['Passive', 'Active', 'Semi-Passive', 'BAP'];
  final List<String> _statuses = ['Available', 'Checked'];

  // Generated IDs
  String _generatedId = '';
  String _generatedTagId = '';
  String _generatedItemId = '';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _valueController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    await _loadDropdownData();
    await _generateIds();
    await _loadDraftData();
    setState(() {
      _isLoadingData = false;
    });
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load categories from repository
      final categories = await widget.assetRepository.getCategories();
      _categories =
          categories.isNotEmpty
              ? categories
              : AppConstants.defaultAssetCategories;

      // Load locations (using default for now, can be expanded)
      _locations = [
        'Warehouse A',
        'Warehouse B',
        'Production Line 1',
        'Production Line 2',
        'Shipping Dock',
        'Receiving Dock',
        'Office',
        'Storage Room',
        'Unknown',
      ];
    } catch (e) {
      // Use default values if API fails
      _categories = AppConstants.defaultAssetCategories;
      _locations = ['Warehouse A', 'Warehouse B', 'Office', 'Unknown'];
    }
  }

  Future<void> _generateIds() async {
    try {
      final assets = await widget.assetRepository.getAssets();

      // Find max ID
      int maxId = 0;
      for (var asset in assets) {
        int? assetId = int.tryParse(asset.id.replaceAll(RegExp(r'[^0-9]'), ''));
        if (assetId != null && assetId > maxId) {
          maxId = assetId;
        }
      }

      final nextId = (maxId + 1).toString();
      _generatedId = nextId;
      _generatedTagId = 'TAG${nextId.padLeft(4, '0')}';
      _generatedItemId = 'ITM${nextId.padLeft(4, '0')}';
    } catch (e) {
      // Fallback to timestamp-based ID
      final now = DateTime.now();
      _generatedId = now.millisecondsSinceEpoch.toString().substring(8);
      _generatedTagId = 'TAG${_generatedId.padLeft(4, '0')}';
      _generatedItemId = 'ITM${_generatedId.padLeft(4, '0')}';
    }
  }

  // Draft Data Management
  String get _draftKey => 'asset_draft_${widget.epc}';

  Future<void> _saveDraftData() async {
    final prefs = await SharedPreferences.getInstance();
    final draftData = {
      'itemName': _itemNameController.text,
      'category': _selectedCategory,
      'location': _selectedLocation,
      'tagType': _selectedTagType,
      'status': _selectedStatus,
      'value': _valueController.text,
      'batchNumber': _batchNumberController.text,
    };
    await prefs.setString(_draftKey, json.encode(draftData));
  }

  Future<void> _loadDraftData() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString(_draftKey);

    if (draftString != null) {
      try {
        final draftData = json.decode(draftString) as Map<String, dynamic>;

        setState(() {
          _itemNameController.text = draftData['itemName'] ?? '';
          _selectedCategory = draftData['category'];
          _selectedLocation = draftData['location'];
          _selectedTagType = draftData['tagType'] ?? 'Passive';
          _selectedStatus = draftData['status'] ?? 'Available';
          _valueController.text = draftData['value'] ?? '';
          _batchNumberController.text = draftData['batchNumber'] ?? '';
        });
      } catch (e) {
        // Ignore draft loading errors
      }
    } else {
      // Set default values
      setState(() {
        _selectedTagType = 'Passive';
        _selectedStatus = 'Available';
      });
    }
  }

  Future<void> _clearDraftData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  void _onFieldChanged() {
    // Auto-save draft when any field changes
    _saveDraftData();
  }

  Future<void> _createAsset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser?.username ?? 'System';
      final now = DateTime.now().toIso8601String();

      final asset = AssetModel(
        id: _generatedId,
        tagId: _generatedTagId,
        epc: widget.epc,
        itemId: _generatedItemId,
        itemName: _itemNameController.text.trim(),
        category: _selectedCategory!,
        status: _selectedStatus!,
        tagType: _selectedTagType!,
        saleDate: now,
        frequency: 'UHF', // Default frequency
        currentLocation: _selectedLocation!,
        zone: 'Unknown', // Default zone
        lastScanTime: now,
        lastScannedBy: currentUser,
        batteryLevel: _selectedTagType == 'Passive' ? '0' : '100',
        batchNumber:
            _batchNumberController.text.trim().isEmpty
                ? 'BATCH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
                : _batchNumberController.text.trim(),
        manufacturingDate: now,
        expiryDate: '', // Optional field
        value:
            _valueController.text.trim().isEmpty
                ? '0'
                : _valueController.text.trim(),
      );

      final success = await widget.assetRepository.createAsset(asset);

      if (!mounted) return;

      if (success) {
        await _clearDraftData(); // Clear draft on success

        setState(() {
          _isCreating = false;
          _isSuccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สร้างสินทรัพย์สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // Return to previous screen after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        setState(() {
          _isCreating = false;
          _errorMessage = 'ไม่สามารถสร้างสินทรัพย์ได้';
        });
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('เกิดข้อผิดพลาด'),
                content: Text('รายละเอียด: ${e.toString()}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ตกลง'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(
        title: const Text('สร้างสินทรัพย์ใหม่'),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      child: _isLoadingData ? _buildLoadingView() : _buildFormView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('กำลังเตรียมข้อมูล...'),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Message
                if (_isSuccess) _buildSuccessMessage(),

                // EPC Info Card
                _buildEpcInfoCard(),

                const SizedBox(height: 24),

                // Generated IDs Card
                _buildGeneratedIdsCard(),

                const SizedBox(height: 24),

                // Form Fields
                _buildFormFields(),

                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null) _buildErrorMessage(),

                // Action Buttons
                _buildActionButtons(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Loading Overlay
        if (_isCreating) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          const Text(
            'สร้างสินทรัพย์สำเร็จ!',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpcInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nfc, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'EPC ที่สแกนได้',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.epc,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedIdsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'รหัสที่สร้างอัตโนมัติ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', _generatedId),
            _buildInfoRow('Tag ID', _generatedTagId),
            _buildInfoRow('Item ID', _generatedItemId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลสินทรัพย์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Item Name
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อสินทรัพย์ *',
                hintText: 'กรอกชื่อสินทรัพย์',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'กรุณากรอกชื่อสินทรัพย์';
                }
                return null;
              },
              onChanged: (value) => _onFieldChanged(),
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่ *',
                border: OutlineInputBorder(),
              ),
              items:
                  _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเลือกหมวดหมู่';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _onFieldChanged();
              },
            ),

            const SizedBox(height: 16),

            // Location Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'ตำแหน่ง *',
                border: OutlineInputBorder(),
              ),
              items:
                  _locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณาเลือกตำแหน่ง';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
                _onFieldChanged();
              },
            ),

            const SizedBox(height: 16),

            // Tag Type and Status Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTagType,
                    decoration: const InputDecoration(
                      labelText: 'ประเภทแท็ก *',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _tagTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTagType = value;
                      });
                      _onFieldChanged();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'สถานะ *',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _onFieldChanged();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Value and Batch Number Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'มูลค่า',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _onFieldChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _batchNumberController,
                    decoration: const InputDecoration(
                      labelText: 'หมายเลขล็อต',
                      hintText: 'จะสร้างอัตโนมัติถ้าไม่กรอก',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onFieldChanged(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800)),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Back Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isCreating ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.purple),
                  label: const Text(
                    'กลับ',
                    style: TextStyle(color: Colors.purple),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Create Button
              if (authService.canCreateAssets)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        (_isCreating || _isSuccess) ? null : _createAsset,
                    icon:
                        _isCreating
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : _isSuccess
                            ? const Icon(Icons.check, color: Colors.white)
                            : const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                    label: Text(
                      _isCreating
                          ? 'กำลังสร้าง...'
                          : _isSuccess
                          ? 'สำเร็จแล้ว'
                          : 'สร้างสินทรัพย์',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isSuccess ? Colors.green.shade700 : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(51),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 24),
                Text(
                  'กำลังสร้างสินทรัพย์...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
