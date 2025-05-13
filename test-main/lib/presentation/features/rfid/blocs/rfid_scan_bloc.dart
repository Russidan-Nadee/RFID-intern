import 'package:flutter/material.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../data/datasources/remote/real_rfid_service.dart';
import '../../../../core/services/rfid_service.dart';

enum RfidScanStatus { initial, scanning, found, notFound, error }

class RfidScanBloc extends ChangeNotifier {
  final ScanRfidUseCase _scanRfidUseCase;
  late final AssetRepository _assetRepository;
  late final RealRfidService _rfidService;
  final TextEditingController guidController = TextEditingController();

  RfidScanStatus _status = RfidScanStatus.initial;
  String _errorMessage = '';
  String? _lastScannedUid;

  RfidScanBloc(this._scanRfidUseCase) {
    _assetRepository = DependencyInjection.get<AssetRepository>();
    // ดึง RfidService และแปลงเป็น RealRfidService
    _rfidService = DependencyInjection.get<RfidService>() as RealRfidService;
  }

  RfidScanStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get lastScannedUid => _lastScannedUid;

  // ฟังก์ชันเพื่อตั้งค่า GUID ที่ผู้ใช้ป้อน
  void setManualGuid(String guid) {
    _rfidService.setManualGuid(guid);
  }

  Future<void> performScan(BuildContext context) async {
    // ตรวจสอบว่าได้ป้อน GUID หรือไม่
    if (guidController.text.isEmpty) {
      _status = RfidScanStatus.error;
      _errorMessage = 'กรุณาระบุ GUID ที่ต้องการค้นหา';
      notifyListeners();
      return;
    }

    // ตั้งค่า GUID ที่ผู้ใช้ป้อน
    setManualGuid(guidController.text);

    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      // สแกน RFID (จะใช้ค่า GUID ที่ตั้งไว้)
      final result = await _scanRfidUseCase.execute(context);
      _lastScannedUid = result['uid'] as String;

      if (result['found'] == true) {
        _status = RfidScanStatus.found;
        notifyListeners();

        Navigator.pushNamed(
          context,
          '/found',
          arguments: {'uid': _lastScannedUid},
        );
      } else {
        _status = RfidScanStatus.notFound;
        notifyListeners();

        Navigator.pushNamed(
          context,
          '/notFound',
          arguments: {'uid': _lastScannedUid},
        );
      }
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void resetStatus() {
    _status = RfidScanStatus.initial;
    _errorMessage = '';
    _lastScannedUid = null;
    notifyListeners();
  }

  @override
  void dispose() {
    guidController.dispose();
    super.dispose();
  }
}
