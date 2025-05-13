import 'package:flutter/material.dart';
import '../../../core/services/rfid_service.dart';
import '../../../domain/repositories/asset_repository.dart';

class ScanRfidUseCase {
  final RfidService _rfidService;
  final AssetRepository _assetRepository;

  ScanRfidUseCase(this._rfidService, this._assetRepository);

  // สแกน RFID และค้นหาสินทรัพย์
  Future<Map<String, dynamic>> execute(BuildContext context) async {
    // ตรวจสอบว่าอุปกรณ์พร้อมใช้งานหรือไม่
    if (!_rfidService.isAvailable()) {
      throw Exception('RFID device is not available');
    }

    // สแกน RFID (ในกรณีนี้จะใช้ค่า GUID ที่ผู้ใช้ป้อน)
    final uid = await _rfidService.scanRfid();

    // ถ้าไม่มีค่า GUID
    if (uid == null || uid.isEmpty) {
      throw Exception('กรุณาระบุ GUID ที่ต้องการค้นหา');
    }

    // ค้นหาสินทรัพย์จาก UID
    final asset = await _assetRepository.findAssetByUid(uid);

    // ส่งผลลัพธ์กลับไป
    return {'uid': uid, 'asset': asset, 'found': asset != null};
  }
}
