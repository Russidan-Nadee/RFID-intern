const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken, requireRole, requirePermissionLevel } = require('../middlewares/authMiddleware');

// Public routes
router.post('/login', authController.login);
router.post('/logout', authController.logout);

// Protected routes
router.get('/me', verifyToken, authController.getCurrentUser);

// Admin only routes
router.get('/users', verifyToken, requireRole('admin'), authController.getAllUsers);
router.post('/users', verifyToken, requireRole('admin'), authController.createUser);
router.put('/users/:userId', verifyToken, authController.updateUser);
router.delete('/users/:userId', verifyToken, requireRole('admin'), authController.deleteUser);

// Password change (admin or self)
router.put('/users/:userId/password', verifyToken, authController.changePassword);

module.exports = router;