const db = require('../config/db');

// ดึงข้อมูลสินทรัพย์ทั้งหมด
exports.getAssets = async (req, res) => {
   try {
      let columns = '*';

      if (req.query.columns) {
         const columnArray = req.query.columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'guid', 'tagId', 'epc', 'itemId', 'itemName',
            'category', 'status', 'tagType', 'frequency', 'currentLocation',
            'zone', 'lastScanTime', 'lastScannedBy', 'batteryLevel'
         ];

         const filteredColumns = columnArray.filter(col => validColumns.includes(col));
         if (filteredColumns.length > 0) {
            columns = filteredColumns.join(', ');
         }
      }

      const query = `SELECT ${columns} FROM rfid_assets_details.assets LIMIT 1000`;
      const [rows] = await db.query(query);

      res.status(200).json({
         success: true,
         count: rows.length,
         data: rows
      });
   } catch (error) {
      console.error('เกิดข้อผิดพลาด:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
         error: error.message
      });
   }
};

// ดึงข้อมูลตาม GUID
exports.getAssetByUid = async (req, res) => {
   try {
      const { uid } = req.params;

      let columns = '*';
      if (req.query.columns) {
         const columnArray = req.query.columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'guid', 'tagId', 'epc', 'itemId', 'itemName',
            'category', 'status', 'tagType', 'frequency', 'currentLocation',
            'zone', 'lastScanTime', 'lastScannedBy', 'batteryLevel'
         ];

         const filteredColumns = columnArray.filter(col => validColumns.includes(col));
         if (filteredColumns.length > 0) {
            columns = filteredColumns.join(', ');
         }
      }

      const query = `SELECT ${columns} FROM rfid_assets_details.assets WHERE guid = ? LIMIT 1`;
      const [rows] = await db.query(query, [uid]);

      if (rows.length === 0) {
         return res.status(404).json({
            success: false,
            message: `ไม่พบสินทรัพย์ที่มี GUID: ${uid}`
         });
      }

      res.status(200).json({
         success: true,
         data: rows[0]
      });
   } catch (error) {
      console.error('เกิดข้อผิดพลาด:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาด',
         error: error.message
      });
   }
};

// ค้นหาสินทรัพย์ตามเงื่อนไข
exports.searchAssets = async (req, res) => {
   try {
      const { category, status, currentLocation, zone } = req.query;

      let whereClause = '';
      const params = [];

      if (category) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'category = ?';
         params.push(category);
      }

      if (status) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'status = ?';
         params.push(status);
      }

      if (currentLocation) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'currentLocation = ?';
         params.push(currentLocation);
      }

      if (zone) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'zone = ?';
         params.push(zone);
      }

      const query = whereClause
         ? `SELECT * FROM rfid_assets_details.assets WHERE ${whereClause} LIMIT 1000`
         : 'SELECT * FROM rfid_assets_details.assets LIMIT 1000';

      const [rows] = await db.query(query, params);

      res.status(200).json({
         success: true,
         count: rows.length,
         data: rows
      });
   } catch (error) {
      console.error('เกิดข้อผิดพลาด:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาด',
         error: error.message
      });
   }
};

// ดึงข้อมูลตาม ID
exports.getAssetById = async (req, res) => {
   try {
      const { id } = req.params;

      const query = `SELECT * FROM rfid_assets_details.assets WHERE id = ? LIMIT 1`;
      const [rows] = await db.query(query, [id]);

      if (rows.length === 0) {
         return res.status(404).json({
            success: false,
            message: `ไม่พบสินทรัพย์ที่มี ID: ${id}`
         });
      }

      res.status(200).json({
         success: true,
         data: rows[0]
      });
   } catch (error) {
      console.error('เกิดข้อผิดพลาด:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาด',
         error: error.message
      });
   }
};