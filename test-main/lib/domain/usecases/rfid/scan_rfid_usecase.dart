import 'package:flutter/material.dart';
import '../../../data/datasources/random_epc_datasource.dart';
import '../../entities/epc_scan_result.dart';
import '../assets/find_asset_by_epc_usecase.dart';

/// UseCase สำหรับการสแกน RFID
class ScanRfidUseCase {
  /// แหล่งข้อมูล EPC (จำลองหรือจริง)
  final EpcDatasource _epcDatasource;

  /// UseCase สำหรับค้นหาสินทรัพย์จาก EPC
  final FindAssetByEpcUseCase _findAssetByEpcUseCase;

  /// สร้าง ScanRfidUseCase
  ScanRfidUseCase(this._epcDatasource, this._findAssetByEpcUseCase);

  /// ดำเนินการสแกน RFID
  ///
  /// [context] คือ BuildContext สำหรับการแสดงผล (ถ้าจำเป็น)
  ///
  /// คืนค่า EpcScanResult ที่มีข้อมูลการสแกนและสินทรัพย์ (ถ้ามี)
  Future<EpcScanResult> execute(BuildContext context) async {
    try {
      // 1. อ่าน EPC จากแหล่งข้อมูล (จำลองหรือเครื่องสแกนจริง)
      final epc = await _epcDatasource.getEpc();

      // ถ้าไม่ได้ EPC
      if (epc == null || epc.isEmpty) {
        return EpcScanResult.error('ไม่สามารถอ่าน EPC ได้');
      }

      // 2. ค้นหาสินทรัพย์จาก EPC
      return await _findAssetByEpcUseCase.execute(epc);
    } catch (e) {
      // กรณีเกิดข้อผิดพลาด
      return EpcScanResult.error('เกิดข้อผิดพลาดในการสแกน: ${e.toString()}');
    }
  }
}
