// ไฟล์นี้เก็บคลาสข้อผิดพลาดต่างๆ ที่อาจเกิดขึ้นในแอป

/// คลาสหลักสำหรับข้อผิดพลาดทั้งหมดในแอป - เป็นแม่แบบให้ข้อผิดพลาดอื่นๆ
class AppException implements Exception {
  /// ข้อความอธิบายข้อผิดพลาด
  final String message;

  /// คำนำหน้าที่บอกประเภทข้อผิดพลาด
  final String? prefix;

  /// URL ที่เกิดข้อผิดพลาด (ถ้ามี)
  final String? url;

  /// รหัสสถานะ HTTP (ถ้ามี)
  final int? statusCode;

  /// สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ค่าจะใช้ค่าเริ่มต้น
  AppException([this.message = '', this.prefix, this.url, this.statusCode]);

  /// แปลงข้อผิดพลาดเป็นข้อความเมื่อต้องการแสดงผล
  @override
  String toString() {
    return "$prefix$message";
  }

  /// ส่งข้อความสำหรับแสดงต่อผู้ใช้
  String getUserFriendlyMessage() {
    return message;
  }
}

/// ข้อผิดพลาดเมื่อดึงข้อมูลไม่สำเร็จ (เช่น ติดต่อเซิร์ฟเวอร์ไม่ได้)
class FetchDataException extends AppException {
  /// สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Error During Communication"
  FetchDataException([String? message, String? url])
    : super(
        message ??
            "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต",
        "FetchDataException: ",
        url,
        500,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและลองใหม่อีกครั้ง";
  }
}

/// ข้อผิดพลาดเมื่อส่งคำขอไม่ถูกต้อง (เช่น ข้อมูลไม่ครบ)
class BadRequestException extends AppException {
  /// สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Invalid Request"
  BadRequestException([String? message, String? url])
    : super(message ?? "คำขอไม่ถูกต้อง", "BadRequestException: ", url, 400);

  @override
  String getUserFriendlyMessage() {
    return "ข้อมูลที่ส่งไม่ถูกต้อง โปรดตรวจสอบและลองใหม่อีกครั้ง";
  }
}

/// ข้อผิดพลาดเกี่ยวกับฐานข้อมูล (เช่น เปิดฐานข้อมูลไม่ได้)
class DatabaseException extends AppException {
  /// สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Database Error"
  DatabaseException([String? message, int? statusCode])
    : super(
        message ?? "เกิดข้อผิดพลาดกับฐานข้อมูล",
        "DatabaseException: ",
        null,
        statusCode ?? 500,
      );

  @override
  String getUserFriendlyMessage() {
    return "เกิดข้อผิดพลาดในการเข้าถึงข้อมูล โปรดลองใหม่ภายหลัง";
  }
}

/// ข้อผิดพลาดเมื่อหาสินทรัพย์ไม่พบ
class AssetNotFoundException extends AppException {
  /// สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Asset Not Found"
  AssetNotFoundException([String? message])
    : super(
        message ?? "ไม่พบสินทรัพย์ที่ต้องการ",
        "AssetNotFoundException: ",
        null,
        404,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่พบสินทรัพย์ที่ต้องการ โปรดตรวจสอบรหัสสินทรัพย์";
  }
}

/// ข้อผิดพลาดเมื่อไม่ได้รับอนุญาต
class UnauthorisedException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  UnauthorisedException([String? message, String? url])
    : super(message ?? "ไม่ได้รับอนุญาต", "UnauthorisedException: ", url, 401);

  @override
  String getUserFriendlyMessage() {
    return "คุณไม่มีสิทธิ์ในการดำเนินการนี้";
  }
}

/// ข้อผิดพลาดเมื่อไม่พบข้อมูลที่ต้องการ
class NotFoundException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  NotFoundException([String? message, String? url])
    : super(
        message ?? "ไม่พบข้อมูลที่ต้องการ",
        "NotFoundException: ",
        url,
        404,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่พบข้อมูลที่ต้องการ โปรดตรวจสอบและลองใหม่อีกครั้ง";
  }
}

/// ข้อผิดพลาดเมื่อมีข้อมูลซ้ำ
class ConflictException extends AppException {
  /// ข้อมูลเพิ่มเติมเกี่ยวกับข้อมูลที่ซ้ำ
  final dynamic existingData;

  /// สร้างข้อผิดพลาดใหม่
  ConflictException([String? message, String? url, this.existingData])
    : super(
        message ?? "ข้อมูลนี้มีอยู่ในระบบแล้ว",
        "ConflictException: ",
        url,
        409,
      );

  @override
  String getUserFriendlyMessage() {
    return "ข้อมูลนี้มีอยู่ในระบบแล้ว ไม่สามารถดำเนินการซ้ำได้";
  }
}

/// ข้อผิดพลาดเกี่ยวกับการตรวจสอบข้อมูล
class ValidationException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  ValidationException([String? message])
    : super(message ?? "ข้อมูลไม่ถูกต้อง", "ValidationException: ", null, 400);

  @override
  String getUserFriendlyMessage() {
    return "ข้อมูลไม่ถูกต้อง: $message";
  }
}

/// ข้อผิดพลาดเมื่อดำเนินการไม่สำเร็จเพราะบางเงื่อนไข
class OperationFailedException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  OperationFailedException([String? message])
    : super(
        message ?? "ไม่สามารถดำเนินการได้",
        "OperationFailedException: ",
        null,
        400,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถดำเนินการได้: $message";
  }
}

/// ข้อผิดพลาดจากการถูกยกเลิกโดยผู้ใช้
class OperationCancelledException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  OperationCancelledException([String? message])
    : super(
        message ?? "การดำเนินการถูกยกเลิก",
        "OperationCancelledException: ",
        null,
        0,
      );

  @override
  String getUserFriendlyMessage() {
    return "การดำเนินการถูกยกเลิก";
  }
}

/// ข้อผิดพลาดเมื่อไม่มีการเชื่อมต่ออินเทอร์เน็ต
class NoInternetException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  NoInternetException([String? message])
    : super(
        message ?? "ไม่มีการเชื่อมต่ออินเทอร์เน็ต",
        "NoInternetException: ",
        null,
        0,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่มีการเชื่อมต่ออินเทอร์เน็ต โปรดตรวจสอบการเชื่อมต่อและลองใหม่อีกครั้ง";
  }
}

/// ข้อผิดพลาดเมื่อเกิดการหมดเวลา
class TimeoutException extends AppException {
  /// สร้างข้อผิดพลาดใหม่
  TimeoutException([String? message, String? url])
    : super(message ?? "การเชื่อมต่อหมดเวลา", "TimeoutException: ", url, 408);

  @override
  String getUserFriendlyMessage() {
    return "การเชื่อมต่อหมดเวลา โปรดตรวจสอบความเร็วอินเทอร์เน็ตและลองใหม่อีกครั้ง";
  }
}

/// NetworkException สำหรับข้อผิดพลาดเกี่ยวกับการเชื่อมต่อเครือข่าย
class NetworkException extends AppException {
  NetworkException([String? message, String? url])
    : super(
        message ?? "ไม่สามารถเชื่อมต่อกับเครือข่ายได้",
        "NetworkException: ",
        url,
        503,
      );

  @override
  String getUserFriendlyMessage() {
    return "ไม่สามารถเชื่อมต่อกับเครือข่ายได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตและลองใหม่อีกครั้ง";
  }
}

/// RfidScanException สำหรับข้อผิดพลาดเกี่ยวกับการสแกน RFID
class RfidScanException extends AppException {
  RfidScanException([String? message])
    : super(
        message ?? "เกิดข้อผิดพลาดในการสแกน RFID",
        "RfidScanException: ",
        null,
        400,
      );

  @override
  String getUserFriendlyMessage() {
    return "เกิดข้อผิดพลาดในการสแกน RFID โปรดลองใหม่อีกครั้ง";
  }
}
