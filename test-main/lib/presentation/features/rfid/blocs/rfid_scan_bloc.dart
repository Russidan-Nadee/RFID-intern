import 'package:flutter/material.dart';
import '../../../../domain/usecases/rfid/scan_rfid_usecase.dart';
import '../../../../domain/usecases/rfid/get_random_uid_usecase.dart';
import '../../../../domain/usecases/rfid/generate_random_asset_info_usecase.dart';
import '../../../../domain/entities/random_asset_info.dart';

enum RfidScanStatus { initial, scanning, found, notFound, error }

class RfidScanBloc extends ChangeNotifier {
  final ScanRfidUseCase _scanRfidUseCase;
  final GetRandomUidUseCase _getRandomUidUseCase;
  final GenerateRandomAssetInfoUseCase _generateRandomAssetInfoUseCase;

  RfidScanStatus _status = RfidScanStatus.initial;
  String _errorMessage = '';
  bool _wantToFind = true;
  String? _lastScannedUid;
  RandomAssetInfo? _randomAssetInfo;

  RfidScanBloc(
    this._scanRfidUseCase,
    this._getRandomUidUseCase,
    this._generateRandomAssetInfoUseCase,
  );

  RfidScanStatus get status => _status;
  String get errorMessage => _errorMessage;
  String? get lastScannedUid => _lastScannedUid;
  RandomAssetInfo? get randomAssetInfo => _randomAssetInfo;

  // กำหนดว่าต้องการเจอสินทรัพย์หรือไม่
  void setFindPreference(bool wantToFind) {
    _wantToFind = wantToFind;
  }

  Future<void> performScan(BuildContext context) async {
    _status = RfidScanStatus.scanning;
    _errorMessage = '';
    notifyListeners();

    try {
      if (_wantToFind) {
        // กรณีกดปุ่ม Yes -> สุ่ม UID แล้วไปหน้า Found
        final uid = await _getRandomUidUseCase.execute();
        _lastScannedUid = uid;

        _status = RfidScanStatus.found;
        notifyListeners();

        Navigator.pushNamed(
          context,
          '/found',
          arguments: {'uid': uid ?? 'Unknown'},
        );
      } else {
        // กรณีกดปุ่ม No -> สุ่มข้อมูลแล้วไปหน้า Not Found
        _randomAssetInfo = await _generateRandomAssetInfoUseCase.execute();
        _status = RfidScanStatus.notFound;
        notifyListeners();

        Navigator.pushNamed(
          context,
          '/notFound',
          arguments: {'randomAssetInfo': _randomAssetInfo},
        );
      }
    } catch (e) {
      _status = RfidScanStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // เพิ่มเมธอดเพื่อสุ่มข้อมูลใหม่
  Future<RandomAssetInfo> generateNewRandomAsset() async {
    _randomAssetInfo = await _generateRandomAssetInfoUseCase.execute();
    notifyListeners();
    return _randomAssetInfo!;
  }

  void resetStatus() {
    _status = RfidScanStatus.initial;
    _errorMessage = '';
    _lastScannedUid = null;
    _randomAssetInfo = null;
    notifyListeners();
  }
}
