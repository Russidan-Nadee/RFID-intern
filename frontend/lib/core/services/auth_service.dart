import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../exceptions/app_exceptions.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Role hierarchy for permission checking (same as backend)
  static const Map<String, int> _roleHierarchy = {
    'viewer': 0,
    'staff': 1,
    'manager': 2,
    'admin': 3,
  };

  AuthService(this._authRepository);

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser?.isAuthenticated ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRole get userRole => _currentUser?.role ?? UserRole.viewer;

  // Authentication methods
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authRepository.login(username, password);
      if (user != null) {
        _currentUser = user.login();
        await _saveUserSession();
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
      await _clearUserSession();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> autoLogin() async {
    _setLoading(true);
    try {
      final savedUser = await _loadUserSession();
      if (savedUser != null && savedUser.isAuthenticated) {
        _currentUser = savedUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Auto login failed: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Permission checking methods based on role hierarchy
  bool hasPermissionLevel(UserRole requiredLevel) {
    if (_currentUser == null) return false;

    final currentLevel = _roleHierarchy[_currentUser!.role.name] ?? 0;
    final requiredLevelValue = _roleHierarchy[requiredLevel.name] ?? 0;

    return currentLevel >= requiredLevelValue;
  }

  bool hasPermission(UserRole requiredRole) {
    return _currentUser?.hasPermissionLevel(requiredRole) ?? false;
  }

  // Feature-specific permission methods (matching backend)
  bool get canViewAssets => true; // All roles can view

  bool get canScanRfid => true; // All roles can scan

  bool get canUpdateAssetStatus => hasPermissionLevel(UserRole.staff); // Staff+

  bool get canCreateAssets => hasPermissionLevel(UserRole.manager); // Manager+

  bool get canEditAssets => hasPermissionLevel(UserRole.manager); // Manager+

  bool get canDeleteAssets =>
      _currentUser?.role == UserRole.admin; // Admin only

  bool get canExportData => hasPermissionLevel(UserRole.staff); // Staff+

  bool get canViewBasicReports => true; // All roles can view basic reports

  bool get canViewAdvancedReports =>
      hasPermissionLevel(UserRole.manager); // Manager+

  bool get canManageUsers => hasPermissionLevel(UserRole.manager); // Manager+

  bool get canAccessSettings =>
      hasPermissionLevel(UserRole.manager); // Manager+

  bool get canManageSystem =>
      _currentUser?.role == UserRole.admin; // Admin only

  // Legacy permission methods (for backward compatibility)
  bool get canBulkUpdate => hasPermissionLevel(UserRole.manager);
  bool get canUpdateAssets => hasPermissionLevel(UserRole.staff);
  bool get canViewReports => true;

  // Role checking methods
  bool get isViewer => _currentUser?.role == UserRole.viewer;
  bool get isStaff => _currentUser?.role == UserRole.staff;
  bool get isManager => _currentUser?.role == UserRole.manager;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  // Utility methods for UI
  bool get canSeeExportButton => canExportData;
  bool get canSeeUpdateButton => canUpdateAssetStatus;
  bool get canSeeCreateButton => canCreateAssets;
  bool get canSeeDeleteButton => canDeleteAssets;
  bool get canSeeSettingsButton => canAccessSettings;

  // Permission checking with specific error messages
  String? getPermissionDeniedMessage(String feature) {
    if (!isAuthenticated) {
      return 'กรุณาเข้าสู่ระบบก่อนใช้งาน';
    }

    switch (feature) {
      case 'updateAsset':
        return canUpdateAssetStatus
            ? null
            : 'ต้องเป็น Staff ขึ้นไปจึงจะอัปเดตสถานะสินทรัพย์ได้';
      case 'createAsset':
        return canCreateAssets
            ? null
            : 'ต้องเป็น Manager ขึ้นไปจึงจะสร้างสินทรัพย์ได้';
      case 'deleteAsset':
        return canDeleteAssets ? null : 'ต้องเป็น Admin จึงจะลบสินทรัพย์ได้';
      case 'exportData':
        return canExportData
            ? null
            : 'ต้องเป็น Staff ขึ้นไปจึงจะส่งออกข้อมูลได้';
      case 'advancedReports':
        return canViewAdvancedReports
            ? null
            : 'ต้องเป็น Manager ขึ้นไปจึงจะดูรายงานขั้นสูงได้';
      case 'manageUsers':
        return canManageUsers
            ? null
            : 'ต้องเป็น Manager ขึ้นไปจึงจะจัดการผู้ใช้ได้';
      case 'accessSettings':
        return canAccessSettings
            ? null
            : 'ต้องเป็น Manager ขึ้นไปจึงจะเข้าถึงการตั้งค่าได้';
      case 'manageSystem':
        return canManageSystem ? null : 'ต้องเป็น Admin จึงจะจัดการระบบได้';
      default:
        return 'ไม่มีสิทธิ์เข้าถึงฟีเจอร์นี้';
    }
  }

  // Navigation permission checking
  bool canNavigateToExport() => canExportData;
  bool canNavigateToSettings() => canAccessSettings;
  bool canNavigateToUserManagement() => canManageUsers;

  Future<List<User>> getAllUsers() async {
    if (!canManageUsers) {
      throw UnauthorisedException('No permission to view users');
    }

    return await _authRepository.getAllUsers();
  }

  // Role Management Methods
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    if (!canManageUsers) {
      throw UnauthorisedException('No permission to update user roles');
    }

    _setLoading(true);
    try {
      final success = await _authRepository.updateUserRole(
        userId,
        newRole.name,
      );
      if (success) {
        // Reload users to reflect changes
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update user role: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> canUpdateUserRole(
    UserRole targetUserRole,
    UserRole newRole,
  ) async {
    if (!canManageUsers) return false;

    try {
      return await _authRepository.canUpdateUserRole(
        _currentUser!.role.name,
        targetUserRole.name,
        newRole.name,
      );
    } catch (e) {
      return false;
    }
  }

  List<UserRole> getAvailableRolesForUser(UserRole targetUserRole) {
    if (!canManageUsers) return [];

    if (isAdmin) {
      // Admin can change any role to any role
      return [
        UserRole.admin,
        UserRole.manager,
        UserRole.staff,
        UserRole.viewer,
      ];
    } else if (isManager) {
      // Manager can only manage Staff and Viewer roles
      if (targetUserRole == UserRole.staff ||
          targetUserRole == UserRole.viewer) {
        return [UserRole.staff, UserRole.viewer];
      }
    }

    return [];
  }

  bool canChangeRoleFromTo(UserRole currentRole, UserRole newRole) {
    if (!canManageUsers) return false;

    final currentLevel = _roleHierarchy[currentRole.name] ?? 0;
    final newLevel = _roleHierarchy[newRole.name] ?? 0;
    final userLevel = _roleHierarchy[_currentUser!.role.name] ?? 0;

    // Can only change roles within your permission level
    return userLevel > currentLevel && userLevel > newLevel;
  }

  // Session management
  Future<void> _saveUserSession() async {
    // Implementation will be added when integrating with shared_preferences
    // For now, keeping in memory only
  }

  Future<User?> _loadUserSession() async {
    // Implementation will be added when integrating with shared_preferences
    return null;
  }

  Future<void> _clearUserSession() async {
    // Implementation will be added when integrating with shared_preferences
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get display name for current user (compatible with existing ProfileService)
  String getUserName() {
    return _currentUser?.username ?? 'Guest User';
  }

  String getUserRole() {
    return _currentUser?.role.displayName ?? 'Guest';
  }

  // For backward compatibility with existing code
  bool isProfileSet() {
    return isAuthenticated;
  }

  // Debug information
  void printUserInfo() {
    if (kDebugMode) {
      print('=== User Info ===');
      print('Username: ${_currentUser?.username}');
      print('Role: ${_currentUser?.role.displayName}');
      print('Authenticated: $isAuthenticated');
      print('Permissions:');
      print('  - Update Assets: $canUpdateAssetStatus');
      print('  - Create Assets: $canCreateAssets');
      print('  - Delete Assets: $canDeleteAssets');
      print('  - Export Data: $canExportData');
      print('  - Advanced Reports: $canViewAdvancedReports');
      print('  - Manage Users: $canManageUsers');
      print('  - Access Settings: $canAccessSettings');
      print('  - Manage System: $canManageSystem');
      print('================');
    }
  }
}
