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

exports.getAssetBytagId = async (req, res) => {
   try {
      const { tagId } = req.params;

      // เพิ่ม log
      console.log('---- DEBUG ----');
      console.log(`Request params: ${JSON.stringify(req.params)}`);
      console.log(`Searching for asset with tagId: ${tagId}`);

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
      console.log(`With params: [${tagId}]`);

      const [rows] = await db.query(query, [tagId]);

      // เพิ่ม log
      console.log(`Query results: Found ${rows.length} rows`);
      if (rows.length > 0) {
         console.log(`First row sample: ${JSON.stringify(rows[0])}`);
      }

      if (rows.length === 0) {
         console.log(`No asset found with tagId: ${tagId}`);
         return res.status(404).json({
            success: false,
            message: `ไม่พบสินทรัพย์ที่มีรหัส: ${tagId}`
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

// สร้างสินทรัพย์ใหม่
exports.createAsset = async (req, res) => {
   try {
      // รับข้อมูลจาก request body
      const {
         id, tagId, epc, itemId, itemName,
         category, status, tagType, frequency, currentLocation,
         zone, lastScanTime, lastScannedBy, batteryLevel, value, batchNumber
      } = req.body;

      // ตรวจสอบข้อมูลที่จำเป็น
      if (!id || !tagId || !epc || !itemName || !category || !status) {
         return res.status(400).json({
            success: false,
            message: 'กรุณาระบุข้อมูลที่จำเป็น (id, tagId, epc, itemName, category, status)'
         });
      }

      // ตรวจสอบว่า EPC ซ้ำหรือไม่
      const [existingEpc] = await db.query(
         'SELECT id FROM rfid_assets_details.assets WHERE epc = ? LIMIT 1',
         [epc]
      );

      if (existingEpc.length > 0) {
         return res.status(409).json({
            success: false,
            message: 'EPC นี้มีอยู่ในระบบแล้ว',
            existingId: existingEpc[0].id
         });
      }

      // ตรวจสอบว่า tagId ซ้ำหรือไม่
      const [existingTagId] = await db.query(
         'SELECT id FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1',
         [tagId]
      );

      if (existingTagId.length > 0) {
         return res.status(409).json({
            success: false,
            message: 'Tag ID นี้มีอยู่ในระบบแล้ว',
            existingId: existingTagId[0].id
         });
      }

      // สร้างสินทรัพย์ใหม่
      const currentTime = new Date().toISOString().slice(0, 19).replace('T', ' ');

      const query = `
         INSERT INTO rfid_assets_details.assets (
            id, tagId, epc, itemId, itemName,
            category, status, tagType, frequency, currentLocation,
            zone, lastScanTime, lastScannedBy, batteryLevel, value, batchNumber,
            createdAt, updatedAt
         ) VALUES (
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?,
            ?, ?
         )
      `;

      const params = [
         id, tagId, epc, itemId || '', itemName,
         category, status, tagType || '', frequency || '', currentLocation || '',
         zone || '', lastScanTime || currentTime, lastScannedBy || '', batteryLevel || '', value || '', batchNumber || '',
         currentTime, currentTime
      ];

      const [result] = await db.query(query, params);

      if (result.affectedRows === 1) {
         res.status(201).json({
            success: true,
            message: 'สร้างสินทรัพย์สำเร็จ',
            data: {
               id,
               tagId,
               epc
            }
         });
      } else {
         throw new Error('ไม่สามารถบันทึกข้อมูลได้');
      }
   } catch (error) {
      console.error('เกิดข้อผิดพลาดในการสร้างสินทรัพย์:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาดในการสร้างสินทรัพย์',
         error: error.message
      });
   }
};

// ตรวจสอบว่า EPC มีอยู่ในระบบแล้วหรือไม่
exports.checkEpcExists = async (req, res) => {
   try {
      const { epc } = req.query;

      if (!epc) {
         return res.status(400).json({
            success: false,
            message: 'กรุณาระบุ EPC ที่ต้องการตรวจสอบ'
         });
      }

      const [rows] = await db.query(
         'SELECT id, tagId, epc FROM rfid_assets_details.assets WHERE epc = ? LIMIT 1',
         [epc]
      );

      const exists = rows.length > 0;

      res.status(200).json({
         success: true,
         exists,
         data: exists ? rows[0] : null
      });
   } catch (error) {
      console.error('เกิดข้อผิดพลาดในการตรวจสอบ EPC:', error);
      res.status(500).json({
         success: false,
         message: 'เกิดข้อผิดพลาดในการตรวจสอบ EPC',
         error: error.message
      });
   }
};

exports.updateAssetStatusToChecked = async (req, res) => {
   try {
      const { tagId } = req.params;
      // รับค่า lastScannedBy จาก request body
      const { lastScannedBy } = req.body;

      if (!tagId) {
         return res.status(400).json({
            success: false,
            message: 'กรุณาระบุ tagId ที่ต้องการอัปเดต'
         });
      }

      const [currentAsset] = await db.query(
         'SELECT * FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1',
         [tagId]
      );

      if (currentAsset.length === 0) {
         return res.status(404).json({
            success: false,
            message: `ไม่พบสินทรัพย์ที่ต้องการอัปเดต: ${tagId}`
         });
      }

      if (currentAsset[0].status !== 'Available') {
         return res.status(400).json({
            success: false,
            message: 'Can update only Available status'
         });
      }

      const currentTime = new Date().toISOString().slice(0, 19).replace('T', ' ');

      // ใช้ชื่อผู้สแกนจาก request หรือใช้ค่าเริ่มต้น 'System' ถ้าไม่มี
      const scannerName = lastScannedBy || 'System';

      const query = `
         UPDATE rfid_assets_details.assets
         SET status = 'Checked', lastScanTime = ?, lastScannedBy = ?
         WHERE tagId = ? LIMIT 1
      `;

      const [result] = await db.query(query, [currentTime, scannerName, tagId]);

      if (result.affectedRows === 0) {
         return res.status(404).json({
            success: false,
            message: `cannot update status: ${tagId}`
         });
      }

      res.status(200).json({
         success: true,
         message: 'Update status successfully',
         data: {
            tagId,
            status: 'Checked',
            lastScanTime: currentTime,
            lastScannedBy: scannerName
         }
      });
   } catch (error) {
      console.error('error in update status:', error);
      res.status(500).json({
         success: false,
         message: 'have error in update status',
         error: error.message
      });
   }
};