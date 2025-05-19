const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');

// โหลดตัวแปรสภาพแวดล้อม
dotenv.config();

// กำหนดเส้นทาง
const assetRoutes = require('./routes/assetRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

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
         assetByUid: '/api/assets/your-tagId-here'
      }
   });
});

// กำหนดเส้นทาง API
app.use('/api/assets', assetRoutes);

// เริ่มเซิร์ฟเวอร์
app.listen(PORT, '0.0.0.0', () => {
   console.log(`Server running on port ${PORT}`);
});