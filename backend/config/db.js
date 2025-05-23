const mysql = require('mysql2/promise');
require('dotenv').config();
const { DatabaseError, ERROR_MESSAGES } = require('../utils/errors');

// สร้าง connection pool
const pool = mysql.createPool({
   host: process.env.DB_HOST,
   user: process.env.DB_USER,
   password: process.env.DB_PASSWORD,
   database: process.env.DB_NAME,
   waitForConnections: true,
   connectionLimit: 10,
   queueLimit: 0
});

// ทดสอบการเชื่อมต่อ
const testConnection = async () => {
   try {
      const conn = await pool.getConnection();
      console.log('✅ เชื่อมต่อฐานข้อมูลสำเร็จ');
      conn.release();
      return true;
   } catch (err) {
      const error = new DatabaseError(ERROR_MESSAGES.DATABASE_CONNECTION, err);
      console.error('❌ ' + error.message);
      if (err) {
         console.error('รายละเอียดข้อผิดพลาด:', err.message);
      }
      throw error;
   }
};

// ฟังก์ชันสำหรับ execute query ที่มีการจัดการ exception
const execute = async (query, params = []) => {
   try {
      const [results] = await pool.query(query, params);
      return results;
   } catch (err) {
      console.error('SQL Query:', query);
      console.error('SQL Params:', params);
      console.error('SQL Error:', err.message);

      throw new DatabaseError(
         `${ERROR_MESSAGES.DATABASE_QUERY}: ${query}`,
         err
      );
   }
};

// Debug logging function
const logQuery = (query, params = []) => {
   console.log('Debug - Executing SQL Query:');
   console.log('Query:', query);
   console.log('Params:', params);
};

// ทดสอบการเชื่อมต่อตอนเริ่มต้น
testConnection().catch(err => {
   console.error('เกิดข้อผิดพลาดในการเชื่อมต่อตอนเริ่มต้น:', err.message);
   if (err.originalError) {
      console.error('รายละเอียดข้อผิดพลาด:', err.originalError.message);
   }
});

module.exports = {
   pool,
   execute,
   testConnection,
   logQuery
};