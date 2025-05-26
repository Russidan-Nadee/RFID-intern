const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');
const {
   verifyToken,
   requireAssetUpdatePermission,
   requireAssetCreatePermission,
   requireAssetDeletionPermission,
   requireExportPermission
} = require('../middlewares/authMiddleware');

// ดึงข้อมูลทั้งหมด - ทุกคนเข้าถึงได้
router.get('/', assetController.getAssets);

// ค้นหาตามเงื่อนไข - ทุกคนเข้าถึงได้
router.get('/search', assetController.searchAssets);

// ตรวจสอบว่า EPC มีอยู่แล้วหรือไม่ - ทุกคนเข้าถึงได้
router.get('/check-epc', assetController.checkEpcExists);

// ดึงข้อมูลตาม ID - ทุกคนเข้าถึงได้
router.get('/id/:id', assetController.getAssetById);

// สร้างสินทรัพย์ใหม่ - Manager+ เท่านั้น
router.post('/', verifyToken, requireAssetCreatePermission(), assetController.createAsset);

// *** เพิ่ม bulk update route - Staff+ เท่านั้น ***
console.log('bulkUpdateAssetStatusToChecked exists:', typeof assetController.bulkUpdateAssetStatusToChecked === 'function');
router.put('/bulk/status/checked', verifyToken, requireAssetUpdatePermission(), assetController.bulkUpdateAssetStatusToChecked);;

// อัปเดตสถานะสินทรัพย์ - Staff+ เท่านั้น
console.log('Function exists:', typeof assetController.updateAssetStatusToChecked === 'function');
if (typeof assetController.updateAssetStatusToChecked === 'function') {
   router.put('/:tagId/status/checked', verifyToken, requireAssetUpdatePermission(), assetController.updateAssetStatusToChecked);
} else {
   console.error('ERROR: updateAssetStatusToChecked is not a function!');
   console.log('Available functions:', Object.keys(assetController));
}

// Export assets - Staff+ เท่านั้น
router.get('/export', verifyToken, requireExportPermission(), assetController.getAssets);

// Delete asset - Admin เท่านั้น
router.delete('/:tagId', verifyToken, requireAssetDeletionPermission(), assetController.deleteAsset);

// Delete all assets - Admin เท่านั้น
router.delete('/all', verifyToken, requireAssetDeletionPermission(), assetController.deleteAllAssets);

// ดึงข้อมูลตาม tagId/GtagId - ทุกคนเข้าถึงได้ (ต้องวางไว้ท้ายสุด)
router.get('/:tagId', assetController.getAssetBytagId);



module.exports = router;