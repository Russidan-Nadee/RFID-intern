import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

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

  // Permission checks
  bool hasPermission(UserRole requiredRole) {
    return _currentUser?.hasPermissionLevel(requiredRole) ?? false;
  }

  bool get canManageUsers => _currentUser?.canManageUsers ?? false;
  bool get canManageSystem => _currentUser?.canManageSystem ?? false;
  bool get canBulkUpdate => _currentUser?.canBulkUpdate ?? false;
  bool get canUpdateAssets => _currentUser?.canUpdateAssets ?? false;
  bool get canViewReports => _currentUser?.canViewReports ?? true;
  bool get canExportData => _currentUser?.canExportData ?? false;

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

  // For backward compatibility with existing code
  bool isProfileSet() {
    return isAuthenticated;
  }
}
