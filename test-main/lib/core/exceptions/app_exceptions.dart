// test-main/lib/core/exceptions/app_exceptions.dart

/// คลาสหลักสำหรับจัดการข้อยกเว้นในแอปพลิเคชัน
class AppException implements Exception {
  // ข้อความอธิบายข้อผิดพลาด
  final String message;
  // คำนำหน้าที่บอกประเภทข้อผิดพลาด
  final String? prefix;
  // URL ที่เกิดข้อผิดพลาด (ถ้ามี)
  final String? url;
  // รหัสข้อผิดพลาด (เพิ่มใหม่)
  final int? errorCode;
  // เวลาที่เกิดข้อผิดพลาด (เพิ่มใหม่)
  final DateTime timestamp;

  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ค่าจะใช้ค่าเริ่มต้น
  AppException([this.message = '', this.prefix, this.url, this.errorCode])
    : timestamp = DateTime.now();

  // แปลงข้อผิดพลาดเป็นข้อความเมื่อต้องการแสดงผล
  @override
  String toString() {
    return "$prefix$message";
  }

  // ดึงข้อความที่เป็นมิตรสำหรับผู้ใช้ (เพิ่มใหม่)
  String getUserFriendlyMessage() {
    return message;
  }
}

/// ข้อผิดพลาดเมื่อดึงข้อมูลไม่สำเร็จ (เช่น ติดต่อเซิร์ฟเวอร์ไม่ได้)
class FetchDataException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Error During Communication"
  FetchDataException([String? message, String? url])
    : super(
        message ?? "Error During Communication",
        "FetchDataException: ",
        url,
        500,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถดึงข้อมูลได้ โปรดตรวจสอบการเชื่อมต่อของคุณ";
  }
}

/// ข้อผิดพลาดเมื่อส่งคำขอไม่ถูกต้อง (เช่น ข้อมูลไม่ครบ)
class BadRequestException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Invalid Request"
  BadRequestException([String? message, String? url])
    : super(message ?? "Invalid Request", "BadRequestException: ", url, 400);

  @override
  String getUserFriendlyMessage() {
    return "คำขอไม่ถูกต้อง โปรดตรวจสอบข้อมูลที่คุณป้อน";
  }
}

/// ข้อผิดพลาดเกี่ยวกับฐานข้อมูล (เช่น เปิดฐานข้อมูลไม่ได้)
class DatabaseException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Database Error"
  DatabaseException([String? message])
    : super(message ?? "Database Error", "DatabaseException: ", null, 500);

  @override
  String getUserFriendlyMessage() {
    return "เกิดข้อผิดพลาดในการเข้าถึงข้อมูล โปรดลองอีกครั้งในภายหลัง";
  }
}

/// ข้อผิดพลาดเมื่อหาสินทรัพย์ไม่พบ
class AssetNotFoundException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Asset Not Found"
  AssetNotFoundException([String? message, String? assetId])
    : super(
        message ??
            (assetId != null ? "Asset Not Found: $assetId" : "Asset Not Found"),
        "AssetNotFoundException: ",
        null,
        404,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่พบสินทรัพย์ที่คุณต้องการ";
  }
}

/// ข้อผิดพลาดเกี่ยวกับเครือข่าย (เพิ่มใหม่)
class NetworkException extends AppException {
  final int? statusCode;
  final String? requestMethod;

  NetworkException({
    String? message,
    String? url,
    this.statusCode,
    this.requestMethod,
  }) : super(
         message ?? "Network Connection Error",
         "NetworkException: ",
         url,
         statusCode,
       );

  @override
  String getUserFriendlyMessage() {
    if (statusCode == null) {
      return "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ";
    } else if (statusCode! >= 500) {
      return "เซิร์ฟเวอร์เกิดข้อผิดพลาด โปรดลองอีกครั้งในภายหลัง";
    } else if (statusCode! == 404) {
      return "ไม่พบบริการที่ร้องขอ";
    } else {
      return "เกิดข้อผิดพลาดในการเชื่อมต่อ: $statusCode";
    }
  }
}

/// ข้อผิดพลาดในการอัปเดตสินทรัพย์ (เพิ่มใหม่)
class AssetUpdateException extends AppException {
  final String? tagId;
  final String? updateType;

  AssetUpdateException({String? message, this.tagId, this.updateType})
    : super(
        message ?? "Failed to update asset",
        "AssetUpdateException: ",
        null,
        400,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถอัปเดตสินทรัพย์ ${tagId != null ? 'รหัส $tagId' : ''} ได้";
  }
}

/// ข้อผิดพลาดในการสร้างสินทรัพย์ (เพิ่มใหม่)
class AssetCreationException extends AppException {
  final String? epc;

  AssetCreationException({String? message, this.epc})
    : super(
        message ?? "Failed to create asset",
        "AssetCreationException: ",
        null,
        400,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถสร้างสินทรัพย์ใหม่ได้";
  }
}

/// ข้อผิดพลาดในการสแกน RFID (เพิ่มใหม่)
class RfidScanException extends AppException {
  RfidScanException([String? message])
    : super(message ?? "RFID Scan Error", "RfidScanException: ", null, 500);

  @override
  String getUserFriendlyMessage() {
    return "เกิดข้อผิดพลาดในการสแกน RFID โปรดลองอีกครั้ง";
  }
}
