const mysql = require('mysql2');

const connection = mysql.createConnection({
   host: '127.0.0.1',
   user: 'root',
   password: 'first27122546',
   database: 'rfid_assets_details'
});

connection.connect((err) => {
   if (err) {
      console.log('เชื่อมต่อไม่สำเร็จ:', err);
   } else {
      console.log('เชื่อมต่อสำเร็จ!');

      // ทดสอบคิวรี่
      connection.query('SELECT * FROM assets LIMIT 5', (err, results) => {
         if (err) {
            console.log('คิวรี่ผิดพลาด:', err);
         } else {
            console.log('ข้อมูล 5 แถวแรก:', results);
         }
         connection.end();
      });
   }
});