const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');

// ดึงข้อมูลทั้งหมด
router.get('/', assetController.getAssets);

// ค้นหาตามเงื่อนไข - ต้องวางก่อน /:uid
router.get('/search', assetController.searchAssets);

// ดึงข้อมูลตาม ID - เพิ่มบรรทัดนี้
router.get('/id/:id', assetController.getAssetById);

// ดึงข้อมูลตาม UID/GUID - ต้องวางไว้หลัง /search และ /id/:id
router.get('/:uid', assetController.getAssetByUid);

module.exports = router;