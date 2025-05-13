const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');

// ดึงข้อมูลทั้งหมด
router.get('/', assetController.getAssets);

// ค้นหาตามเงื่อนไข - ต้องวางก่อน /:uid
router.get('/search', assetController.searchAssets);

// ดึงข้อมูลตาม UID/GUID - ต้องวางไว้หลัง /search
router.get('/:uid', assetController.getAssetByUid);

module.exports = router;