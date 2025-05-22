const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { errorHandler, notFoundHandler } = require('./middlewares/errorHandler');

// โหลดตัวแปรสภาพแวดล้อม
dotenv.config();

// กำหนดเส้นทาง
const assetRoutes = require('./routes/assetRoutes');
const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Debug middleware - เพิ่มการ log request สำหรับ debugging
app.use((req, res, next) => {
   console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
   next();
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// เส้นทางหลัก
app.get('/', (req, res) => {
   res.json({
      message: 'ยินดีต้อนรับสู่ API ระบบจัดการสินทรัพย์ RFID',
      endpoints: {
         allAssets: '/api/assets',
         assetsByColumns: '/api/assets?columns=id,tagId,category',
         searchAssets: '/api/assets/search?category=Storage&status=Available',
         assetByUid: '/api/assets/your-tagId-here',
         login: '/api/auth/login',
         currentUser: '/api/auth/me',
         allUsers: '/api/auth/users'

      }
   });
});

// กำหนดเส้นทาง API
app.use('/api/assets', assetRoutes);
app.use('/api/auth', authRoutes);

// 404 Handler - ต้องวางหลังจากกำหนดเส้นทางทั้งหมด
app.use(notFoundHandler);

// Error Handler - ต้องวางหลังสุดเสมอ
app.use(errorHandler);

// เริ่มเซิร์ฟเวอร์
app.listen(PORT, '0.0.0.0', () => {
   console.log(`Server running on port ${PORT}`);
   console.log(`API available at http://localhost:${PORT}/api/assets`);
   console.log(`Auth API available at http://localhost:${PORT}/api/auth`);
});

// จัดการข้อผิดพลาดที่ไม่ได้จัดการ (Uncaught exceptions)
process.on('uncaughtException', (error) => {
   console.error('Uncaught Exception:', error);
   // ในสภาพแวดล้อมจริง อาจจะต้องปิดเซิร์ฟเวอร์อย่างปลอดภัยที่นี่
});

// จัดการ Promise rejection ที่ไม่ได้จัดการ
process.on('unhandledRejection', (reason, promise) => {
   console.error('Unhandled Rejection at:', promise, 'reason:', reason);
   // ในสภาพแวดล้อมจริง อาจจะต้องปิดเซิร์ฟเวอร์อย่างปลอดภัยที่นี่
});