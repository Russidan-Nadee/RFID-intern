const jwt = require('jsonwebtoken');
const { execute } = require('../config/db');
const { UnauthorisedException, ERROR_MESSAGES, HTTP_STATUS } = require('../utils/errors');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-here';

// Middleware to verify JWT token
const verifyToken = async (req, res, next) => {
   try {
      const token = req.header('Authorization')?.replace('Bearer ', '') ||
         req.cookies?.token ||
         req.query?.token;

      if (!token) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'ไม่พบ token การยืนยันตัวตน'
         });
      }

      // Verify token
      const decoded = jwt.verify(token, JWT_SECRET);

      // Get user from database to ensure user still exists
      const query = 'SELECT id, username, role FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
      const users = await execute(query, [decoded.userId]);

      if (users.length === 0) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'ผู้ใช้ไม่ถูกต้องหรือถูกลบออกจากระบบ'
         });
      }

      // Add user info to request
      req.user = {
         userId: users[0].id,
         username: users[0].username,
         role: users[0].role
      };

      next();
   } catch (error) {
      if (error.name === 'JsonWebTokenError') {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'Token ไม่ถูกต้อง'
         });
      } else if (error.name === 'TokenExpiredError') {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'Token หมดอายุ กรุณาเข้าสู่ระบบใหม่'
         });
      } else {
         return res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
            success: false,
            message: 'เกิดข้อผิดพลาดในการตรวจสอบสิทธิ์'
         });
      }
   }
};

// Middleware to check specific role permissions
const requireRole = (roles) => {
   return (req, res, next) => {
      if (!req.user) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'กรุณาเข้าสู่ระบบก่อน'
         });
      }

      const userRole = req.user.role;
      const allowedRoles = Array.isArray(roles) ? roles : [roles];

      if (!allowedRoles.includes(userRole)) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'ไม่มีสิทธิ์เข้าถึงข้อมูลนี้'
         });
      }

      next();
   };
};

// Middleware to check hierarchical permissions
const requirePermissionLevel = (requiredLevel) => {
   const roleHierarchy = {
      'viewer': 0,
      'staff': 1,
      'manager': 2,
      'admin': 3
   };

   return (req, res, next) => {
      if (!req.user) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: 'กรุณาเข้าสู่ระบบก่อน'
         });
      }

      const userLevel = roleHierarchy[req.user.role] || 0;
      const requiredLevelValue = roleHierarchy[requiredLevel] || 0;

      if (userLevel < requiredLevelValue) {
         return res.status(HTTP_STATUS.UNAUTHORIZED).json({
            success: false,
            message: `ต้องมีสิทธิ์ระดับ ${requiredLevel} ขึ้นไป`
         });
      }

      next();
   };
};

// Feature-Specific Permission Functions
const requireAssetUpdatePermission = () => {
   return requirePermissionLevel('staff');
};

const requireAssetCreatePermission = () => {
   return requirePermissionLevel('manager');
};

const requireAssetDeletionPermission = () => {
   return requireRole('admin');
};

const requireExportPermission = () => {
   return requirePermissionLevel('staff');
};

const requireAdvancedReportsPermission = () => {
   return requirePermissionLevel('manager');
};

const requireUserManagementPermission = () => {
   return requirePermissionLevel('manager');
};

const requireSettingsAccessPermission = () => {
   return requirePermissionLevel('manager');
};

const requireSystemManagementPermission = () => {
   return requireRole('admin');
};

// Optional authentication (for routes that work with or without auth)
const optionalAuth = async (req, res, next) => {
   try {
      const token = req.header('Authorization')?.replace('Bearer ', '') ||
         req.cookies?.token ||
         req.query?.token;

      if (token) {
         const decoded = jwt.verify(token, JWT_SECRET);
         const query = 'SELECT id, username, role FROM rfid_assets_details.users WHERE id = ? LIMIT 1';
         const users = await execute(query, [decoded.userId]);

         if (users.length > 0) {
            req.user = {
               userId: users[0].id,
               username: users[0].username,
               role: users[0].role
            };
         }
      }

      next();
   } catch (error) {
      // For optional auth, continue even if token is invalid
      next();
   }
};

module.exports = {
   verifyToken,
   requireRole,
   requirePermissionLevel,
   optionalAuth,
   requireAssetUpdatePermission,
   requireAssetCreatePermission,
   requireAssetDeletionPermission,
   requireExportPermission,
   requireAdvancedReportsPermission,
   requireUserManagementPermission,
   requireSettingsAccessPermission,
   requireSystemManagementPermission
};