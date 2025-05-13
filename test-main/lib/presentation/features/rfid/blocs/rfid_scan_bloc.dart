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
    _rfidService = DependencyInjection.get<RfidService>() as RealRfidService;
  }

  RfidScanStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get lastScannedUid => _lastScannedUid;

  void setManualGuid(String guid) {
    _rfidService.setManualGuid(guid);
  }

  Future<void> performScan(BuildContext context) async {
    if (guidController.text.isEmpty) {
      _status = RfidScanStatus.error;
      _errorMessage = 'กรุณาระบุ GUID ที่ต้องการค้นหา';
      notifyListeners();
      return;
    }

    setManualGuid(guidController.text);
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _scanRfidUseCase.execute(context);
      _lastScannedUid = result['uid'] as String;

      // ตรวจสอบว่าเจอข้อมูลหรือไม่ โดยใช้ _assetRepository
      final asset = await _assetRepository.findAssetByUid(_lastScannedUid!);

      if (asset != null) {
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
