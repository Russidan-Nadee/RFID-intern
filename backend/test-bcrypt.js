const bcrypt = require('bcryptjs');

const testHash = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewvUqDQpbgPCr7cC';
const testPasswords = ['admin123', 'admin', 'password', '123456', 'test'];

console.log('Testing bcrypt comparisons...');
testPasswords.forEach(async (pwd, index) => {
   try {
      const result = await bcrypt.compare(pwd, testHash);
      console.log(`${index + 1}. "${pwd}" -> ${result}`);
   } catch (error) {
      console.log(`${index + 1}. "${pwd}" -> ERROR: ${error.message}`);
   }
});