// rfid-asset-api/utils/errors.js

// กำหนดค่าคงที่สำหรับ HTTP status codes
const HTTP_STATUS = {
   OK: 200,
   CREATED: 201,
   BAD_REQUEST: 400,
   UNAUTHORIZED: 401,
   NOT_FOUND: 404,
   CONFLICT: 409,
   INTERNAL_SERVER_ERROR: 500
};

// กำหนดข้อความแสดงข้อผิดพลาดที่ใช้บ่อย
const ERROR_MESSAGES = {
   DATABASE_CONNECTION: 'เกิดข้อผิดพลาดในการเชื่อมต่อฐานข้อมูล',
   DATABASE_QUERY: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
   ASSET_NOT_FOUND: 'ไม่พบสินทรัพย์ที่ต้องการ',
   INVALID_REQUEST: 'คำขอไม่ถูกต้อง',
   REQUIRED_FIELDS: 'กรุณาระบุข้อมูลที่จำเป็น',
   DUPLICATE_EPC: 'EPC นี้มีอยู่ในระบบแล้ว',
   DUPLICATE_TAG_ID: 'Tag ID นี้มีอยู่ในระบบแล้ว',
   UNKNOWN_ERROR: 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
   ASSET_UPDATE_ERROR: 'ไม่สามารถอัปเดตสินทรัพย์ได้',
   INVALID_STATUS: 'Can update only Available status',
   UNAUTHORIZED: 'ไม่ได้รับอนุญาต',
};

// Custom Error Classes
class AppError extends Error {
   constructor(message, statusCode = HTTP_STATUS.INTERNAL_SERVER_ERROR) {
      super(message);
      this.statusCode = statusCode;
      this.name = this.constructor.name;
      Error.captureStackTrace(this, this.constructor);
   }
}

class DatabaseError extends AppError {
   constructor(message = ERROR_MESSAGES.DATABASE_QUERY, originalError = null) {
      super(message, HTTP_STATUS.INTERNAL_SERVER_ERROR);
      this.originalError = originalError;
   }
}

class NotFoundError extends AppError {
   constructor(message = ERROR_MESSAGES.ASSET_NOT_FOUND) {
      super(message, HTTP_STATUS.NOT_FOUND);
   }
}

class ValidationError extends AppError {
   constructor(message = ERROR_MESSAGES.INVALID_REQUEST) {
      super(message, HTTP_STATUS.BAD_REQUEST);
   }
}

class ConflictError extends AppError {
   constructor(message, existingId = null) {
      super(message, HTTP_STATUS.CONFLICT);
      this.existingId = existingId;
   }
}

class UnauthorisedException extends AppError {
   constructor(message = ERROR_MESSAGES.INVALID_REQUEST) {
      super(message, HTTP_STATUS.UNAUTHORIZED);
   }
}

module.exports = {
   HTTP_STATUS,
   ERROR_MESSAGES,
   AppError,
   DatabaseError,
   NotFoundError,
   ValidationError,
   ConflictError,
   UnauthorisedException,
};