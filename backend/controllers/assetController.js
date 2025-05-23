const { execute, logQuery } = require('../config/db');
const {
   NotFoundError,
   ValidationError,
   ConflictError,
   UnauthorisedException,
   ERROR_MESSAGES,
   HTTP_STATUS
} = require('../utils/errors');

// ดึงข้อมูลสินทรัพย์ทั้งหมด
exports.getAssets = async (req, res, next) => {
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
      logQuery(query); // Debug logging
      const rows = await execute(query);

      res.status(HTTP_STATUS.OK).json({
         success: true,
         count: rows.length,
         data: rows
      });
   } catch (error) {
      next(error);
   }
};

exports.getAssetBytagId = async (req, res, next) => {
   try {
      const { tagId } = req.params;

      if (!tagId) {
         throw new ValidationError('กรุณาระบุ tagId ที่ต้องการค้นหา');
      }

      // Debug logging
      console.log('---- DEBUG ----');
      console.log(`Request params: ${JSON.stringify(req.params)}`);
      console.log(`Searching for asset with tagId: ${tagId}`);

      let columns = '*';
      if (req.query.columns) {
         // Debug logging
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

         // Debug logging
         console.log(`Filtered columns: ${columns}`);
      }

      // แก้ไขคำสั่ง SQL และเพิ่ม debug logging
      const query = `SELECT ${columns} FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1`;
      console.log(`Executing SQL: ${query}`);
      console.log(`With params: [${tagId}]`);

      const rows = await execute(query, [tagId]);

      // Debug logging
      console.log(`Query results: Found ${rows.length} rows`);
      if (rows.length > 0) {
         console.log(`First row sample: ${JSON.stringify(rows[0])}`);
      }

      if (rows.length === 0) {
         console.log(`No asset found with tagId: ${tagId}`);
         throw new NotFoundError(`ไม่พบสินทรัพย์ที่มีรหัส: ${tagId}`);
      }

      console.log('Success! Returning data to client');
      res.status(HTTP_STATUS.OK).json({
         success: true,
         data: rows[0]
      });
   } catch (error) {
      console.error('---- ERROR DETAILS ----');
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);

      // Log SQL details if available
      if (error.sql) {
         console.error('SQL error:', error.sql);
         console.error('SQL state:', error.sqlState);
         console.error('SQL message:', error.sqlMessage);
      }
      console.error('-----------------------');

      next(error);
   }
};

// ค้นหาสินทรัพย์ตามเงื่อนไข
exports.searchAssets = async (req, res, next) => {
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

      logQuery(query, params); // Debug logging
      const rows = await execute(query, params);

      res.status(HTTP_STATUS.OK).json({
         success: true,
         count: rows.length,
         data: rows
      });
   } catch (error) {
      next(error);
   }
};

// ดึงข้อมูลตาม ID
exports.getAssetById = async (req, res, next) => {
   try {
      const { id } = req.params;

      if (!id) {
         throw new ValidationError('กรุณาระบุ ID ที่ต้องการค้นหา');
      }

      const query = `SELECT * FROM rfid_assets_details.assets WHERE id = ? LIMIT 1`;
      logQuery(query, [id]); // Debug logging
      const rows = await execute(query, [id]);

      if (rows.length === 0) {
         throw new NotFoundError(`ไม่พบสินทรัพย์ที่มี ID: ${id}`);
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         data: rows[0]
      });
   } catch (error) {
      next(error);
   }
};

// สร้างสินทรัพย์ใหม่ - Manager+ เท่านั้น
exports.createAsset = async (req, res, next) => {
   try {
      // ตรวจสอบสิทธิ์การสร้างสินทรัพย์
      if (req.user && (req.user.role === 'staff' || req.user.role === 'viewer')) {
         throw new UnauthorisedException('ไม่มีสิทธิ์สร้างสินทรัพย์ ต้องเป็น Manager หรือ Admin');
      }

      // รับข้อมูลจาก request body
      const {
         id, tagId, epc, itemId, itemName,
         category, status, tagType, frequency, currentLocation,
         zone, lastScanTime, lastScannedBy, batteryLevel, value, batchNumber
      } = req.body;

      // Debug logging
      console.log('Create Asset Request Body:', req.body);

      // ตรวจสอบข้อมูลที่จำเป็น
      if (!id || !tagId || !epc || !itemName || !category || !status) {
         throw new ValidationError(ERROR_MESSAGES.REQUIRED_FIELDS);
      }

      // ตรวจสอบว่า EPC ซ้ำหรือไม่
      const checkEpcQuery = 'SELECT id FROM rfid_assets_details.assets WHERE epc = ? LIMIT 1';
      logQuery(checkEpcQuery, [epc]); // Debug logging
      const existingEpc = await execute(checkEpcQuery, [epc]);

      if (existingEpc.length > 0) {
         throw new ConflictError(ERROR_MESSAGES.DUPLICATE_EPC, existingEpc[0].id);
      }

      // ตรวจสอบว่า tagId ซ้ำหรือไม่
      const checkTagQuery = 'SELECT id FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1';
      logQuery(checkTagQuery, [tagId]); // Debug logging
      const existingTagId = await execute(checkTagQuery, [tagId]);

      if (existingTagId.length > 0) {
         throw new ConflictError(ERROR_MESSAGES.DUPLICATE_TAG_ID, existingTagId[0].id);
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

      logQuery(query, params); // Debug logging
      const result = await execute(query, params);

      if (result.affectedRows === 1) {
         res.status(HTTP_STATUS.CREATED).json({
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
      next(error);
   }
};

// ตรวจสอบว่า EPC มีอยู่ในระบบแล้วหรือไม่
exports.checkEpcExists = async (req, res, next) => {
   try {
      const { epc } = req.query;

      if (!epc) {
         throw new ValidationError('กรุณาระบุ EPC ที่ต้องการตรวจสอบ');
      }

      const query = 'SELECT id, tagId, epc FROM rfid_assets_details.assets WHERE epc = ? LIMIT 1';
      logQuery(query, [epc]); // Debug logging
      const rows = await execute(query, [epc]);

      const exists = rows.length > 0;

      res.status(HTTP_STATUS.OK).json({
         success: true,
         exists,
         data: exists ? rows[0] : null
      });
   } catch (error) {
      next(error);
   }
};

// อัปเดตสถานะสินทรัพย์ - Staff+ เท่านั้น
exports.updateAssetStatusToChecked = async (req, res, next) => {
   try {
      // ตรวจสอบสิทธิ์การอัปเดตสถานะ
      if (req.user && req.user.role === 'viewer') {
         throw new UnauthorisedException('ไม่มีสิทธิ์อัปเดตสถานะสินทรัพย์ ต้องเป็น Staff ขึ้นไป');
      }

      const { tagId } = req.params;

      // เพิ่ม logging เพื่อตรวจสอบ request body
      console.log('Full request body:', req.body);
      console.log('Request headers:', req.headers);

      // รับค่า lastScannedBy จาก request body
      const { lastScannedBy } = req.body;
      console.log('lastScannedBy extracted from body:', lastScannedBy);

      if (!tagId) {
         throw new ValidationError('กรุณาระบุ tagId ที่ต้องการอัปเดต');
      }

      const checkAssetQuery = 'SELECT * FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1';
      logQuery(checkAssetQuery, [tagId]); // Debug logging
      const currentAsset = await execute(checkAssetQuery, [tagId]);

      if (currentAsset.length === 0) {
         throw new NotFoundError(`ไม่พบสินทรัพย์ที่ต้องการอัปเดต: ${tagId}`);
      }

      if (currentAsset[0].status !== 'Available') {
         throw new ValidationError(ERROR_MESSAGES.INVALID_STATUS);
      }

      const currentTime = new Date().toISOString().slice(0, 19).replace('T', ' ');

      // แก้ไขให้รับประกันว่าจะใช้ค่า lastScannedBy ถ้ามี
      let scannerName = 'System'; // ค่าเริ่มต้น
      if (typeof lastScannedBy === 'string' && lastScannedBy.trim() !== '') {
         scannerName = lastScannedBy.trim();
      }
      console.log('Final scannerName value:', scannerName);

      const query = `
         UPDATE rfid_assets_details.assets
         SET status = 'Checked', lastScanTime = ?, lastScannedBy = ?
         WHERE tagId = ? LIMIT 1
      `;

      console.log('SQL parameters:', [currentTime, scannerName, tagId]);
      logQuery(query, [currentTime, scannerName, tagId]); // Debug logging
      const result = await execute(query, [currentTime, scannerName, tagId]);

      if (result.affectedRows === 0) {
         throw new Error(`cannot update status: ${tagId}`);
      }

      res.status(HTTP_STATUS.OK).json({
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
      next(error);
   }
};

// ลบสินทรัพย์ - Admin เท่านั้น
exports.deleteAsset = async (req, res, next) => {
   try {
      // ตรวจสอบสิทธิ์การลบ (Admin เท่านั้น)
      if (!req.user || req.user.role !== 'admin') {
         throw new UnauthorisedException('ไม่มีสิทธิ์ลบสินทรัพย์ ต้องเป็น Admin เท่านั้น');
      }

      const { tagId } = req.params;

      if (!tagId) {
         throw new ValidationError('กรุณาระบุ tagId ที่ต้องการลบ');
      }

      // ตรวจสอบว่ามีสินทรัพย์อยู่จริง
      const checkAssetQuery = 'SELECT * FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1';
      logQuery(checkAssetQuery, [tagId]);
      const asset = await execute(checkAssetQuery, [tagId]);

      if (asset.length === 0) {
         throw new NotFoundError(`ไม่พบสินทรัพย์ที่ต้องการลบ: ${tagId}`);
      }

      // ลบสินทรัพย์
      const deleteQuery = 'DELETE FROM rfid_assets_details.assets WHERE tagId = ? LIMIT 1';
      logQuery(deleteQuery, [tagId]);
      const result = await execute(deleteQuery, [tagId]);

      if (result.affectedRows === 0) {
         throw new Error(`ไม่สามารถลบสินทรัพย์ได้: ${tagId}`);
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'ลบสินทรัพย์สำเร็จ',
         data: {
            tagId,
            deletedBy: req.user.username,
            deletedAt: new Date().toISOString()
         }
      });
   } catch (error) {
      next(error);
   }
};

// ลบสินทรัพย์ทั้งหมด - Admin เท่านั้น
exports.deleteAllAssets = async (req, res, next) => {
   try {
      // ตรวจสอบสิทธิ์การลบ (Admin เท่านั้น)
      if (!req.user || req.user.role !== 'admin') {
         throw new UnauthorisedException('ไม่มีสิทธิ์ลบสินทรัพย์ทั้งหมด ต้องเป็น Admin เท่านั้น');
      }

      // เพิ่มการยืนยันผ่าน query parameter เพื่อความปลอดภัย
      const { confirm } = req.query;
      if (confirm !== 'DELETE_ALL_CONFIRM') {
         throw new ValidationError('กรุณายืนยันการลบด้วย query parameter: ?confirm=DELETE_ALL_CONFIRM');
      }

      // นับจำนวนสินทรัพย์ก่อนลบ
      const countQuery = 'SELECT COUNT(*) as total FROM rfid_assets_details.assets';
      logQuery(countQuery);
      const countResult = await execute(countQuery);
      const totalAssets = countResult[0].total;

      if (totalAssets === 0) {
         return res.status(HTTP_STATUS.OK).json({
            success: true,
            message: 'ไม่มีสินทรัพย์ที่ต้องลบ',
            data: {
               deletedCount: 0,
               deletedBy: req.user.username,
               deletedAt: new Date().toISOString()
            }
         });
      }

      // ลบสินทรัพย์ทั้งหมด
      const deleteQuery = 'DELETE FROM rfid_assets_details.assets';
      logQuery(deleteQuery);
      const result = await execute(deleteQuery);

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: `ลบสินทรัพย์ทั้งหมดสำเร็จ (${totalAssets} รายการ)`,
         data: {
            deletedCount: totalAssets,
            deletedBy: req.user.username,
            deletedAt: new Date().toISOString()
         }
      });
   } catch (error) {
      next(error);
   }
};

// Export สินทรัพย์ - Staff+ เท่านั้น
exports.exportAssets = async (req, res, next) => {
   try {
      // ตรวจสอบสิทธิ์การ Export
      if (req.user && req.user.role === 'viewer') {
         throw new UnauthorisedException('ไม่มีสิทธิ์ Export ข้อมูล ต้องเป็น Staff ขึ้นไป');
      }

      // รับพารามิเตอร์การกรองข้อมูล
      const {
         category,
         status,
         currentLocation,
         zone,
         format = 'json',
         columns
      } = req.query;

      // สร้าง WHERE clause สำหรับการกรอง
      let whereClause = '';
      const params = [];

      if (category) {
         whereClause += whereClause ? ' AND ' : 'WHERE ';
         whereClause += 'category = ?';
         params.push(category);
      }

      if (status) {
         whereClause += whereClause ? ' AND ' : 'WHERE ';
         whereClause += 'status = ?';
         params.push(status);
      }

      if (currentLocation) {
         whereClause += whereClause ? ' AND ' : 'WHERE ';
         whereClause += 'currentLocation = ?';
         params.push(currentLocation);
      }

      if (zone) {
         whereClause += whereClause ? ' AND ' : 'WHERE ';
         whereClause += 'zone = ?';
         params.push(zone);
      }

      // กำหนดคอลัมน์ที่จะ export
      let selectColumns = '*';
      if (columns) {
         const columnArray = columns.split(',').map(col => col.trim());
         const validColumns = [
            'id', 'tagId', 'epc', 'itemId', 'itemName',
            'category', 'status', 'tagType', 'frequency', 'currentLocation',
            'zone', 'lastScanTime', 'lastScannedBy', 'batteryLevel',
            'value', 'batchNumber', 'manufacturingDate', 'expiryDate'
         ];

         const filteredColumns = columnArray.filter(col => validColumns.includes(col));
         if (filteredColumns.length > 0) {
            selectColumns = filteredColumns.join(', ');
         }
      }

      const query = `SELECT ${selectColumns} FROM rfid_assets_details.assets ${whereClause}`;
      logQuery(query, params);
      const rows = await execute(query, params);

      // กำหนด response headers สำหรับการ download
      const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
      const filename = `assets_export_${timestamp}`;

      if (format.toLowerCase() === 'csv') {
         // Export เป็น CSV
         if (rows.length === 0) {
            return res.status(HTTP_STATUS.OK).json({
               success: true,
               message: 'ไม่มีข้อมูลที่ตรงกับเงื่อนไขการค้นหา',
               data: []
            });
         }

         // สร้าง CSV headers
         const headers = Object.keys(rows[0]).join(',');

         // สร้าง CSV rows
         const csvRows = rows.map(row =>
            Object.values(row).map(value =>
               typeof value === 'string' && value.includes(',')
                  ? `"${value}"`
                  : value
            ).join(',')
         );

         const csvContent = [headers, ...csvRows].join('\n');

         res.setHeader('Content-Type', 'text/csv');
         res.setHeader('Content-Disposition', `attachment; filename="${filename}.csv"`);
         res.status(HTTP_STATUS.OK).send(csvContent);
      } else {
         // Export เป็น JSON (default)
         res.status(HTTP_STATUS.OK).json({
            success: true,
            exportInfo: {
               totalRecords: rows.length,
               exportedBy: req.user.username,
               exportedAt: new Date().toISOString(),
               filters: { category, status, currentLocation, zone },
               format: 'json'
            },
            data: rows
         });
      }
   } catch (error) {
      next(error);
   }
};