// ไฟล์นี้เก็บคลาสข้อผิดพลาดต่างๆ ที่อาจเกิดขึ้นในแอป

// คลาสหลักสำหรับข้อผิดพลาดทั้งหมดในแอป - เป็นแม่แบบให้ข้อผิดพลาดอื่นๆ
class AppException implements Exception {
  // ข้อความอธิบายข้อผิดพลาด
  final String message;
  // คำนำหน้าที่บอกประเภทข้อผิดพลาด
  final String? prefix;
  // URL ที่เกิดข้อผิดพลาด (ถ้ามี)
  final String? url;

  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ค่าจะใช้ค่าเริ่มต้น
  AppException([this.message = '', this.prefix, this.url]);

  // แปลงข้อผิดพลาดเป็นข้อความเมื่อต้องการแสดงผล
  @override
  String toString() {
    return "$prefix$message";
  }
}

// ข้อผิดพลาดเมื่อดึงข้อมูลไม่สำเร็จ (เช่น ติดต่อเซิร์ฟเวอร์ไม่ได้)
class FetchDataException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Error During Communication"
  FetchDataException([String? message, String? url])
    : super(
        message ?? "Error During Communication",
        "FetchDataException: ",
        url,
      );
}

// ข้อผิดพลาดเมื่อส่งคำขอไม่ถูกต้อง (เช่น ข้อมูลไม่ครบ)
class BadRequestException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Invalid Request"
  BadRequestException([String? message, String? url])
    : super(message ?? "Invalid Request", "BadRequestException: ", url);
}

// ข้อผิดพลาดเกี่ยวกับฐานข้อมูล (เช่น เปิดฐานข้อมูลไม่ได้)
class DatabaseException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Database Error"
  DatabaseException([String? message])
    : super(message ?? "Database Error", "DatabaseException: ");
}

// ข้อผิดพลาดเมื่อหาสินทรัพย์ไม่พบ
class AssetNotFoundException extends AppException {
  // สร้างข้อผิดพลาดใหม่ ถ้าไม่ใส่ message จะใช้ "Asset Not Found"
  AssetNotFoundException([String? message])
    : super(message ?? "Asset Not Found", "AssetNotFoundException: ");
}
