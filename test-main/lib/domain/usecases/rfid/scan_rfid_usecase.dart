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

    // สแกน RFID
    final uid = await _rfidService.scanRfid();

    // ถ้าสแกนไม่สำเร็จ
    if (uid == null) {
      throw Exception('Failed to scan RFID tag');
    }

    // ค้นหาสินทรัพย์จาก UID
    final asset = await _assetRepository.findAssetByUid(uid);

    // ส่งผลลัพธ์กลับไป
    return {'uid': uid, 'asset': asset, 'found': asset != null};
  }

  // สแกน RFID โดยมีการกำหนด UID ล่วงหน้า (สำหรับการทดสอบ)
  Future<Map<String, dynamic>> executeWithUid(
    String uid,
    BuildContext context,
  ) async {
    // ค้นหาสินทรัพย์จาก UID
    final asset = await _assetRepository.findAssetByUid(uid);

    // ส่งผลลัพธ์กลับไป
    return {'uid': uid, 'asset': asset, 'found': asset != null};
  }
}
