import 'package:rfid_project/core/exceptions/app_exceptions.dart';
import 'package:rfid_project/domain/repositories/asset_repository.dart';

/// คลาสสำหรับตรวจสอบความถูกต้องของข้อมูลสินทรัพย์
class AssetValidator {
  final AssetRepository repository;

  // หมวดหมู่ที่ระบบรองรับ
  static const List<String> validCategories = [
    'Finished Good',
    'Equipment',
    'Raw Material',
    'Tool',
    'Work in Progress',
    'Packaging',
  ];

  // สถานะที่ระบบรองรับ
  static const List<String> validStatuses = ['Available', 'Checked'];

  // ประเภทแท็กที่ระบบรองรับ
  static const List<String> validTagTypes = [
    'Passive',
    'Active',
    'Semi-Passive',
    'BAP',
  ];

  AssetValidator(this.repository);

  /// ตรวจสอบความถูกต้องของ EPC
  Future<void> validateEpc(String epc) async {
    // ตรวจสอบว่า EPC ไม่เป็นค่าว่าง
    if (epc.isEmpty) {
      throw ValidationException('EPC ไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบรูปแบบ EPC (เช่น ขึ้นต้นด้วย "urn:epc:id:")
    final bool isValidFormat =
        epc.startsWith('urn:epc:id:') ||
        RegExp(r'^[0-9A-Fa-f]{24}$').hasMatch(epc);
    if (!isValidFormat) {
      throw ValidationException(
        'รูปแบบ EPC ไม่ถูกต้อง: $epc - ต้องขึ้นต้นด้วย "urn:epc:id:" หรือเป็นเลขฐาน 16 จำนวน 24 หลัก',
      );
    }

    // ตรวจสอบความยาว
    if (epc.length < 20 || epc.length > 50) {
      throw ValidationException(
        'ความยาว EPC ไม่ถูกต้อง: ${epc.length} อักขระ - ต้องอยู่ระหว่าง 20-50 อักขระ',
      );
    }

    // ตรวจสอบว่ามีอักขระที่ไม่อนุญาตหรือไม่
    if (epc.contains(RegExp(r'[^\w\d\-:.]'))) {
      throw ValidationException(
        'EPC มีอักขระที่ไม่อนุญาต: $epc - อนุญาตเฉพาะตัวอักษร ตัวเลข และสัญลักษณ์ -:. เท่านั้น',
      );
    }

    // ตรวจสอบความซ้ำซ้อนกับฐานข้อมูล
    try {
      final exists = await repository.checkEpcExists(epc);
      if (exists) {
        throw ConflictException('EPC นี้มีอยู่ในระบบแล้ว: $epc');
      }
    } catch (e) {
      if (e is ConflictException) rethrow;

      // กรณีเกิดข้อผิดพลาดในการตรวจสอบ
      throw DatabaseException('ไม่สามารถตรวจสอบ EPC ได้: $e');
    }
  }

  /// ตรวจสอบความถูกต้องของข้อมูลสินทรัพย์
  void validateAssetData(Map<String, dynamic> data) {
    // ตรวจสอบ ID
    if (data['id'] == null || data['id'].toString().isEmpty) {
      throw ValidationException('ID สินทรัพย์ไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบ Tag ID
    if (data['tagId'] == null || data['tagId'].toString().isEmpty) {
      throw ValidationException('Tag ID ไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบรูปแบบ Tag ID
    if (!RegExp(r'^TAG\d{4}$').hasMatch(data['tagId'])) {
      throw ValidationException(
        'รูปแบบ Tag ID ไม่ถูกต้อง: ${data['tagId']} - ต้องมีรูปแบบ TAGxxxx โดย x เป็นตัวเลข',
      );
    }

    // ตรวจสอบ itemName
    if (data['itemName'] == null || data['itemName'].toString().isEmpty) {
      throw ValidationException('ชื่อสินทรัพย์ไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบ category
    if (data['category'] == null || data['category'].toString().isEmpty) {
      throw ValidationException('หมวดหมู่ไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบว่า category อยู่ในรายการที่กำหนด
    if (!validCategories.contains(data['category'])) {
      throw ValidationException(
        'หมวดหมู่ไม่ถูกต้อง: ${data['category']} - ต้องเป็นหนึ่งใน $validCategories',
      );
    }

    // ตรวจสอบ status
    if (data['status'] == null || data['status'].toString().isEmpty) {
      throw ValidationException('สถานะไม่สามารถเป็นค่าว่างได้');
    }

    // ตรวจสอบว่า status อยู่ในรายการที่กำหนด
    if (!validStatuses.contains(data['status'])) {
      throw ValidationException(
        'สถานะไม่ถูกต้อง: ${data['status']} - ต้องเป็นหนึ่งใน $validStatuses',
      );
    }

    // ตรวจสอบว่า tagType อยู่ในรายการที่กำหนด (ถ้ามีค่า)
    if (data['tagType'] != null && data['tagType'].toString().isNotEmpty) {
      if (!validTagTypes.contains(data['tagType'])) {
        throw ValidationException(
          'ประเภทแท็กไม่ถูกต้อง: ${data['tagType']} - ต้องเป็นหนึ่งใน $validTagTypes',
        );
      }
    }

    // ตรวจสอบว่า batteryLevel เป็นตัวเลขที่ถูกต้อง (ถ้ามีค่า)
    if (data['batteryLevel'] != null &&
        data['batteryLevel'].toString().isNotEmpty) {
      if (data['batteryLevel'] != '0' &&
          !RegExp(r'^\d+$').hasMatch(data['batteryLevel'])) {
        throw ValidationException(
          'ระดับแบตเตอรี่ไม่ถูกต้อง: ${data['batteryLevel']} - ต้องเป็นตัวเลขเท่านั้น',
        );
      }

      final batteryLevel = int.tryParse(data['batteryLevel'].toString()) ?? -1;
      if (batteryLevel < 0 || batteryLevel > 100) {
        throw ValidationException(
          'ระดับแบตเตอรี่ไม่ถูกต้อง: $batteryLevel - ต้องอยู่ระหว่าง 0-100',
        );
      }
    }
  }
}
