const db = require('../config/db');

// ดึงข้อมูลสินทรัพย์ทั้งหมด
exports.getAssets = async (req, res) => {
   try {
      let columns = '*';

      if (req.query.columns) {
         const columnArray = req.query.columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'tagId', 'epc', 'itemId', 'itemName',
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

exports.getAssetByUid = async (req, res) => {
   try {
      const { uid } = req.params;

      // เพิ่ม log
      console.log('---- DEBUG ----');
      console.log(`Request params: ${JSON.stringify(req.params)}`);
      console.log(`Searching for asset with UID: ${uid}`);

      let columns = '*';
      if (req.query.columns) {
         // เพิ่ม log
         console.log(`Request columns: ${req.query.columns}`);

         const columnArray = req.query.columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'tagId', 'epc', 'itemId', 'itemName',
            'category', 'status', 'tagType', 'frequency', 'currentLocation',
            'zone', 'lastScanTime', 'lastScannedBy', 'batteryLevel'
         ];

         const filteredColumns = columnArray.filter(col => validColumns.includes(col));
         if (filteredColumns.length > 0) {
            columns = filteredColumns.join(', ');
         }

         // เพิ่ม log
         console.log(`Filtered columns: ${columns}`);
      }

      // แก้ไขคำสั่ง SQL และเพิ่ม log
      const query = `SELECT ${columns} FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1`;
      console.log(`Executing SQL: ${query}`);
      console.log(`With params: [${uid}]`);

      const [rows] = await db.query(query, [uid]);

      // เพิ่ม log
      console.log(`Query results: Found ${rows.length} rows`);
      if (rows.length > 0) {
         console.log(`First row sample: ${JSON.stringify(rows[0])}`);
      }

      if (rows.length === 0) {
         console.log(`No asset found with tagId: ${uid}`);
         return res.status(404).json({
            success: false,
            message: `ไม่พบสินทรัพย์ที่มีรหัส: ${uid}`
         });
      }

      console.log('Success! Returning data to client');
      res.status(200).json({
         success: true,
         data: rows[0]
      });
   } catch (error) {
      // เพิ่ม log แบบละเอียด
      console.error('---- ERROR DETAILS ----');
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);
      console.error('SQL error:', error.sql);
      console.error('SQL state:', error.sqlState);
      console.error('SQL message:', error.sqlMessage);
      console.error('-----------------------');

      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาดในการดึงข้อมูล',
         error: error.message,
         sqlMessage: error.sqlMessage || 'Unknown SQL error'
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