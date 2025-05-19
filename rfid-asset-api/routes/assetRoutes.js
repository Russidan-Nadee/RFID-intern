const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');

// ดึงข้อมูลทั้งหมด
router.get('/', assetController.getAssets);

// ค้นหาตามเงื่อนไข - ต้องวางก่อน /:tagId
router.get('/search', assetController.searchAssets);

// ตรวจสอบว่า EPC มีอยู่แล้วหรือไม่ - ต้องวางก่อน /:tagId
router.get('/check-epc', assetController.checkEpcExists);

// ดึงข้อมูลตาม ID - เพิ่มบรรทัดนี้
router.get('/id/:id', assetController.getAssetById);

// สร้างสินทรัพย์ใหม่
router.post('/', assetController.createAsset);

// ดึงข้อมูลตาม tagId/GtagId - ต้องวางไว้ท้ายสุด
router.get('/:tagId', assetController.getAssetBytagId);

module.exports = router;