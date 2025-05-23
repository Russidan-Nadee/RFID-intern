const bcrypt = require('bcryptjs');
const password = '1234';
const saltRounds = 12; // ตรงกับที่ใช้ในโค้ด (saltRounds = 12)

bcrypt.hash(password, saltRounds, (err, hash) => {
   if (err) console.error(err);
   console.log('Password: 1234');
   console.log('New hash:', hash);
});