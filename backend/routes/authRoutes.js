const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const {
   verifyToken,
   requireRole,
   requireUserManagementPermission,
   requireSystemManagementPermission
} = require('../middlewares/authMiddleware');

// Public routes
router.post('/login', authController.login);
router.post('/logout', authController.logout);

// Protected routes
router.get('/me', verifyToken, authController.getCurrentUser);

// User Management routes - Manager+ can access
router.get('/users', verifyToken, requireUserManagementPermission(), authController.getAllUsers);
router.post('/users', verifyToken, requireUserManagementPermission(), authController.createUser);
router.put('/users/:userId', verifyToken, authController.updateUser);
router.delete('/users/:userId', verifyToken, requireUserManagementPermission(), authController.deleteUser);

// Password change - admin or self (handled in controller)
router.put('/users/:userId/password', verifyToken, authController.changePassword);

// System Management routes - Admin only
router.get('/system/settings', verifyToken, requireSystemManagementPermission(), authController.getSystemSettings);
router.put('/system/settings', verifyToken, requireSystemManagementPermission(), authController.updateSystemSettings);

// Advanced user operations - Admin only
router.put('/users/:userId/role', verifyToken, authController.updateUserRole);
router.put('/users/:userId/status', verifyToken, requireRole('admin'), authController.updateUserStatus);

module.exports = router;