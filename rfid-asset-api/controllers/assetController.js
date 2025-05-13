const db = require('../config/db');

// ดึงข้อมูลสินทรัพย์ทั้งหมด
exports.getAssets = async (req, res) => {
   try {
      let columns = '*';

      if (req.query.columns) {
         const columnArray = req.query.columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'guid', 'tagid', 'epc', 'itemId', 'itemName',
            'category', 'status', 'tagType', 'frequency', 'department',
            'zone', 'lastScanTime', 'value', 'securityClearance'
         ];

         const filteredColumns = columnArray.filter(col => validColumns.includes(col));
         if (filteredColumns.length > 0) {
            columns = filteredColumns.join(', ');
         }
      }

      const query = `SELECT ${columns} FROM assets LIMIT 1000`;
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
         // โค้ดเหมือนด้านบน
      }

      const query = `SELECT ${columns} FROM assets WHERE guid = ? LIMIT 1`;
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
      const { category, status, department, zone } = req.query;

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

      if (department) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'department = ?';
         params.push(department);
      }

      if (zone) {
         whereClause += whereClause ? ' AND ' : '';
         whereClause += 'zone = ?';
         params.push(zone);
      }

      const query = whereClause
         ? `SELECT * FROM assets WHERE ${whereClause} LIMIT 1000`
         : 'SELECT * FROM assets LIMIT 1000';

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