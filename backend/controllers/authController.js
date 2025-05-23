const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { execute, logQuery } = require('../config/db');
const {
   NotFoundError,
   ValidationError,
   ConflictError,
   UnauthorisedException,
   ERROR_MESSAGES,
   HTTP_STATUS
} = require('../utils/errors');

// Secret key for JWT (should be in environment variable in production)
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-here';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';

// Login user
exports.login = async (req, res, next) => {
   try {
      const { username, password } = req.body;
      console.log('Login attempt:', { username, password });

      if (!username || !password) {
         throw new ValidationError('กรุณาระบุ username และ password');
      }

      // Find user by username
      const query = 'SELECT * FROM rfid_assets_details.users WHERE username = ? LIMIT 1';
      logQuery(query, [username]);
      const users = await execute(query, [username]);

      if (users.length === 0) {
         throw new UnauthorisedException('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }

      const user = users[0];
      console.log('User found:', { username: user.username, hash: user.password_hash });
      console.log('=== DEBUG INFO ===');
      console.log('User object keys:', Object.keys(user));
      console.log('Password hash field:', user.password_hash);
      console.log('Hash length:', user.password_hash?.length);
      console.log('Input password:', password);
      console.log('bcrypt version:', require('bcryptjs/package.json').version);
      console.log('==================')

      // Verify password
      console.log('Comparing passwords...');
      const isPasswordValid = await bcrypt.compare(password, user.password_hash);
      console.log('Password valid:', isPasswordValid);
      if (!isPasswordValid) {
         throw new UnauthorisedException('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }

      // Generate JWT token
      const token = jwt.sign(
         {
            userId: user.id,
            username: user.username,
            role: user.role
         },
         JWT_SECRET,
         { expiresIn: JWT_EXPIRES_IN }
      );

      // Update last login time
      const updateQuery = 'UPDATE rfid_assets_details.users SET lastLoginTime = NOW() WHERE id = ?';
      await execute(updateQuery, [user.id]);

      // Return user data and token
      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'เข้าสู่ระบบสำเร็จ',
         data: {
            id: user.id,
            username: user.username,
            role: user.role,
            isAuthenticated: true,
            lastLoginTime: new Date().toISOString(),
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
         },
         token
      });
   } catch (error) {
      next(error);
   }
};

// Logout user
exports.logout = async (req, res, next) => {
   try {
      // In JWT-based auth, logout is handled client-side by removing the token
      // But we can add token blacklisting here if needed

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'ออกจากระบบสำเร็จ'
      });
   } catch (error) {
      next(error);
   }
};

// Get current user
exports.getCurrentUser = async (req, res, next) => {
   try {
      const userId = req.user.userId; // From auth middleware

      const query = 'SELECT * FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
      logQuery(query, [userId]);
      const users = await execute(query, [userId]);

      if (users.length === 0) {
         throw new NotFoundError('ไม่พบข้อมูลผู้ใช้');
      }

      const user = users[0];

      res.status(HTTP_STATUS.OK).json({
         success: true,
         data: {
            id: user.id,
            username: user.username,
            role: user.role,
            isAuthenticated: true,
            lastLoginTime: user.lastLoginTime,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
         }
      });
   } catch (error) {
      next(error);
   }
};

// Get all users (Manager+ can access)
exports.getAllUsers = async (req, res, next) => {
   try {
      // Check if user has permission (Manager+ can access)
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      if ((roleHierarchy[userRole] || 0) < roleHierarchy['manager']) {
         throw new UnauthorisedException('ไม่มีสิทธิ์เข้าถึงข้อมูลนี้ ต้องเป็น Manager ขึ้นไป');
      }

      const query = 'SELECT id, username, role, lastLoginTime, createdAt, updatedAt FROM rfid_assets_details.users ORDER BY createdAt DESC';
      logQuery(query);
      const users = await execute(query);

      res.status(HTTP_STATUS.OK).json({
         success: true,
         count: users.length,
         data: users.map(user => ({
            id: user.id,
            username: user.username,
            role: user.role,
            isAuthenticated: false, // We don't track this in DB
            lastLoginTime: user.lastLoginTime,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt
         }))
      });
   } catch (error) {
      next(error);
   }
};

// Create new user (Manager+ can create)
exports.createUser = async (req, res, next) => {
   try {
      // Check if user has permission (Manager+ can create)
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      if ((roleHierarchy[userRole] || 0) < roleHierarchy['manager']) {
         throw new UnauthorisedException('ไม่มีสิทธิ์สร้างผู้ใช้ใหม่ ต้องเป็น Manager ขึ้นไป');
      }

      const { username, password, role } = req.body;

      if (!username || !password || !role) {
         throw new ValidationError('กรุณาระบุ username, password และ role');
      }

      // Validate role
      const validRoles = ['admin', 'manager', 'staff', 'viewer'];
      if (!validRoles.includes(role)) {
         throw new ValidationError(`role ต้องเป็นหนึ่งใน: ${validRoles.join(', ')}`);
      }

      // Manager can't create Admin users (only Admin can create Admin)
      if (role === 'admin' && userRole !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถสร้างผู้ใช้ Admin ได้');
      }

      // Check if username already exists
      const checkQuery = 'SELECT id FROM rfid_assets_details.users WHERE username = ? LIMIT 1';
      const existingUsers = await execute(checkQuery, [username]);

      if (existingUsers.length > 0) {
         throw new ConflictError('ชื่อผู้ใช้นี้มีอยู่ในระบบแล้ว');
      }

      // Hash password
      const saltRounds = 12;
      const passwordHash = await bcrypt.hash(password, saltRounds);

      // Insert new user
      const insertQuery = `
         INSERT INTO rfid_assets_details.users (username, password_hash, role, createdAt, updatedAt)
         VALUES (?, ?, ?, NOW(), NOW())
      `;

      const result = await execute(insertQuery, [username, passwordHash, role]);

      if (result.affectedRows === 1) {
         // Get the created user
         const getUserQuery = 'SELECT id, username, role, createdAt, updatedAt FROM rfid_assets_details.users WHERE id = ?';
         const newUsers = await execute(getUserQuery, [result.insertId]);
         const newUser = newUsers[0];

         res.status(HTTP_STATUS.CREATED).json({
            success: true,
            message: 'สร้างผู้ใช้สำเร็จ',
            data: {
               id: newUser.id,
               username: newUser.username,
               role: newUser.role,
               isAuthenticated: false,
               lastLoginTime: null,
               createdAt: newUser.createdAt,
               updatedAt: newUser.updatedAt
            }
         });
      } else {
         throw new Error('ไม่สามารถสร้างผู้ใช้ได้');
      }
   } catch (error) {
      next(error);
   }
};

// Update user (Manager+ or self)
exports.updateUser = async (req, res, next) => {
   try {
      const { userId } = req.params;
      const { username, role } = req.body;
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      // Check permissions
      const isManager = (roleHierarchy[userRole] || 0) >= roleHierarchy['manager'];
      const isSelf = req.user.userId === parseInt(userId);

      if (!isManager && !isSelf) {
         throw new UnauthorisedException('ไม่มีสิทธิ์แก้ไขข้อมูลผู้ใช้นี้');
      }

      // If not manager+, can't change role
      if (!isManager && role) {
         throw new UnauthorisedException('ไม่มีสิทธิ์เปลี่ยนบทบาทผู้ใช้');
      }

      // Manager can't promote to Admin (only Admin can do that)
      if (role === 'admin' && userRole !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถกำหนดบทบาท Admin ได้');
      }

      let updateFields = [];
      let updateValues = [];

      if (username) {
         // Check if new username already exists
         const checkQuery = 'SELECT id FROM rfid_assets_details.users WHERE username = ? AND id != ? LIMIT 1';
         const existingUsers = await execute(checkQuery, [username, userId]);

         if (existingUsers.length > 0) {
            throw new ConflictError('ชื่อผู้ใช้นี้มีอยู่ในระบบแล้ว');
         }

         updateFields.push('username = ?');
         updateValues.push(username);
      }

      if (role && isManager) {
         const validRoles = ['admin', 'manager', 'staff', 'viewer'];
         if (!validRoles.includes(role)) {
            throw new ValidationError(`role ต้องเป็นหนึ่งใน: ${validRoles.join(', ')}`);
         }

         updateFields.push('role = ?');
         updateValues.push(role);
      }

      if (updateFields.length === 0) {
         throw new ValidationError('ไม่มีข้อมูลที่ต้องการอัปเดต');
      }

      updateFields.push('updatedAt = NOW()');
      updateValues.push(userId);

      const updateQuery = `UPDATE rfid_assets_details.users SET ${updateFields.join(', ')} WHERE id = ?`;
      const result = await execute(updateQuery, updateValues);

      if (result.affectedRows === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการอัปเดต');
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'อัปเดตข้อมูลผู้ใช้สำเร็จ'
      });
   } catch (error) {
      next(error);
   }
};

// Delete user (Manager+ can delete, but not themselves)
exports.deleteUser = async (req, res, next) => {
   try {
      const { userId } = req.params;
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      // Check if user has permission (Manager+)
      if ((roleHierarchy[userRole] || 0) < roleHierarchy['manager']) {
         throw new UnauthorisedException('ไม่มีสิทธิ์ลบผู้ใช้ ต้องเป็น Manager ขึ้นไป');
      }

      // Can't delete self
      if (req.user.userId === parseInt(userId)) {
         throw new ValidationError('ไม่สามารถลบบัญชีตัวเองได้');
      }

      // Check if target user exists and get their role
      const getUserQuery = 'SELECT role FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
      const targetUsers = await execute(getUserQuery, [userId]);

      if (targetUsers.length === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการลบ');
      }

      // Manager can't delete Admin (only Admin can delete Admin)
      if (targetUsers[0].role === 'admin' && userRole !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถลบผู้ใช้ Admin ได้');
      }

      const deleteQuery = 'DELETE FROM rfid_assets_details.users WHERE id = ?';
      const result = await execute(deleteQuery, [userId]);

      if (result.affectedRows === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการลบ');
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'ลบผู้ใช้สำเร็จ'
      });
   } catch (error) {
      next(error);
   }
};

// Change password (Manager+ or self)
exports.changePassword = async (req, res, next) => {
   try {
      const { userId } = req.params;
      const { oldPassword, newPassword } = req.body;
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      // Check permissions (manager+ or self)
      const isManager = (roleHierarchy[userRole] || 0) >= roleHierarchy['manager'];
      const isSelf = req.user.userId === parseInt(userId);

      if (!isManager && !isSelf) {
         throw new UnauthorisedException('ไม่มีสิทธิ์เปลี่ยนรหัสผ่านของผู้ใช้นี้');
      }

      if (!oldPassword || !newPassword) {
         throw new ValidationError('กรุณาระบุรหัสผ่านเก่าและรหัสผ่านใหม่');
      }

      // Get current user
      const getUserQuery = 'SELECT password_hash FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
      const users = await execute(getUserQuery, [userId]);

      if (users.length === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้');
      }

      const user = users[0];

      // Verify old password (skip for manager+ changing other user's password)
      if (isSelf) {
         const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);
         if (!isOldPasswordValid) {
            throw new ValidationError('รหัสผ่านเก่าไม่ถูกต้อง');
         }
      }

      // Hash new password
      const saltRounds = 12;
      const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

      // Update password
      const updateQuery = 'UPDATE rfid_assets_details.users SET password_hash = ?, updatedAt = NOW() WHERE id = ?';
      const result = await execute(updateQuery, [newPasswordHash, userId]);

      if (result.affectedRows === 0) {
         throw new Error('ไม่สามารถเปลี่ยนรหัสผ่านได้');
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'เปลี่ยนรหัสผ่านสำเร็จ'
      });
   } catch (error) {
      next(error);
   }
};

// Update user role (Admin only)
exports.updateUserRole = async (req, res, next) => {
   try {
      const { userId } = req.params;
      const { role } = req.body;
      const userRole = req.user.role;
      const roleHierarchy = { 'viewer': 0, 'staff': 1, 'manager': 2, 'admin': 3 };

      // Manager+ can change roles
      if ((roleHierarchy[userRole] || 0) < roleHierarchy['manager']) {
         throw new UnauthorisedException('ต้องเป็น Manager ขึ้นไปจึงจะเปลี่ยนบทบาทผู้ใช้ได้');
      }

      if (!role) {
         throw new ValidationError('กรุณาระบุบทบาทใหม่');
      }

      const validRoles = ['admin', 'manager', 'staff', 'viewer'];
      if (!validRoles.includes(role)) {
         throw new ValidationError(`role ต้องเป็นหนึ่งใน: ${validRoles.join(', ')}`);
      }

      // Can't change own role
      if (req.user.userId === parseInt(userId)) {
         throw new ValidationError('ไม่สามารถเปลี่ยนบทบาทตัวเองได้');
      }

      // Get target user's current role
      const getUserQuery = 'SELECT role FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
      const targetUsers = await execute(getUserQuery, [userId]);

      if (targetUsers.length === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการอัปเดต');
      }

      const targetCurrentRole = targetUsers[0].role;

      // Permission checks based on user role
      if (userRole === 'manager') {
         // Manager can only change staff/viewer roles
         if (!['staff', 'viewer'].includes(targetCurrentRole)) {
            throw new UnauthorisedException('Manager สามารถเปลี่ยนบทบาทของ Staff และ Viewer เท่านั้น');
         }
         // Manager can only assign staff/viewer roles  
         if (!['staff', 'viewer'].includes(role)) {
            throw new UnauthorisedException('Manager สามารถกำหนดบทบาทเป็น Staff หรือ Viewer เท่านั้น');
         }
      } else if (userRole === 'admin') {
         // Admin can change any role except other admins (optional safety)
         // Remove this check if admin should be able to change other admin roles
         if (targetCurrentRole === 'admin' && role !== 'admin') {
            // Optional: prevent demoting other admins
            // Remove these lines if not needed
         }
      }

      const updateQuery = 'UPDATE rfid_assets_details.users SET role = ?, updatedAt = NOW() WHERE id = ?';
      const result = await execute(updateQuery, [role, userId]);

      if (result.affectedRows === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการอัปเดต');
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'เปลี่ยนบทบาทผู้ใช้สำเร็จ',
         data: { userId, newRole: role }
      });
   } catch (error) {
      next(error);
   }
};
// Update user status (Admin only)
exports.updateUserStatus = async (req, res, next) => {
   try {
      // Only Admin can change user status
      if (req.user.role !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถเปลี่ยนสถานะผู้ใช้ได้');
      }

      const { userId } = req.params;
      const { isActive } = req.body;

      if (typeof isActive !== 'boolean') {
         throw new ValidationError('กรุณาระบุสถานะผู้ใช้ (true/false)');
      }

      // Can't change own status
      if (req.user.userId === parseInt(userId)) {
         throw new ValidationError('ไม่สามารถเปลี่ยนสถานะตัวเองได้');
      }

      // Note: This assumes you have an 'isActive' column in users table
      // If not, you might want to add it or use a different approach
      const updateQuery = 'UPDATE rfid_assets_details.users SET isActive = ?, updatedAt = NOW() WHERE id = ?';
      const result = await execute(updateQuery, [isActive, userId]);

      if (result.affectedRows === 0) {
         throw new NotFoundError('ไม่พบผู้ใช้ที่ต้องการอัปเดต');
      }

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'เปลี่ยนสถานะผู้ใช้สำเร็จ',
         data: { userId, isActive }
      });
   } catch (error) {
      next(error);
   }
};

// Get system settings (Admin only)
exports.getSystemSettings = async (req, res, next) => {
   try {
      // Only Admin can access system settings
      if (req.user.role !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถเข้าถึงการตั้งค่าระบบ');
      }

      // This is a placeholder - implement based on your system settings structure
      const settings = {
         system: {
            maxUsers: 100,
            sessionTimeout: 24,
            allowRegistration: false,
            maintenanceMode: false
         },
         security: {
            passwordMinLength: 8,
            requireUppercase: true,
            requireNumbers: true,
            sessionTimeout: 24
         },
         features: {
            enableExport: true,
            enableReports: true,
            enableUserManagement: true
         }
      };

      res.status(HTTP_STATUS.OK).json({
         success: true,
         data: settings
      });
   } catch (error) {
      next(error);
   }
};

// Update system settings (Admin only)
exports.updateSystemSettings = async (req, res, next) => {
   try {
      // Only Admin can update system settings
      if (req.user.role !== 'admin') {
         throw new UnauthorisedException('เฉพาะ Admin เท่านั้นที่สามารถแก้ไขการตั้งค่าระบบ');
      }

      const { settings } = req.body;

      if (!settings) {
         throw new ValidationError('กรุณาระบุการตั้งค่าที่ต้องการอัปเดต');
      }

      // This is a placeholder - implement based on your system settings storage
      // You might want to store settings in a separate table or configuration file

      res.status(HTTP_STATUS.OK).json({
         success: true,
         message: 'อัปเดตการตั้งค่าระบบสำเร็จ',
         data: settings
      });
   } catch (error) {
      next(error);
   }
}; 