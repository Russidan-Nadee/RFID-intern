const mysql = require('mysql2');

const connection = mysql.createConnection({
   host: '127.0.0.1',  // ลองใช้ IP นี้
   user: 'root',
   password: 'first27122546',
   database: 'rfid_assets_details'
});

connection.connect((err) => {
   if (err) {
      console.log('เชื่อมต่อไม่สำเร็จ:', err);
   } else {
      console.log('เชื่อมต่อสำเร็จ!');
      connection.end();
   }
});
