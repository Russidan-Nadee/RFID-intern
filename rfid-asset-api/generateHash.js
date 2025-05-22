const bcrypt = require('bcryptjs');
const password = 'admin123';
const saltRounds = 12; // ตรงกับที่ใช้ในโค้ด (saltRounds = 12)
bcrypt.hash(password, saltRounds, (err, hash) => {
   if (err) console.error(err);
   console.log('New hash:', hash);
});