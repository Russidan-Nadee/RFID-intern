// rfid-asset-api/middlewares/errorHandler.js
const { AppError, HTTP_STATUS } = require('../utils/errors');

// Middleware สำหรับจัดการข้อผิดพลาดทั้งหมด
const errorHandler = (err, req, res, next) => {
   console.error('Error:', err);

   // ถ้าเป็น Custom Error จะมี statusCode
   if (err instanceof AppError) {
      return res.status(err.statusCode).json({
         success: false,
         message: err.message,
         ...(err.existingId && { existingId: err.existingId })
      });
   }

   // ถ้าไม่ใช่ Custom Error ให้ถือว่าเป็น Internal Server Error
   return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
   });
};

// 404 Handler - เรียกเมื่อไม่พบเส้นทาง
const notFoundHandler = (req, res, next) => {
   res.status(HTTP_STATUS.NOT_FOUND).json({
      success: false,
      message: `ไม่พบเส้นทาง: ${req.originalUrl}`
   });
};

module.exports = { errorHandler, notFoundHandler };