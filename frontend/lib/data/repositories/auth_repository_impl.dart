import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_service.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/error_handler.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<User?> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      if (response != null) {
        return User.fromMap(response);
      }
      return null;
    } catch (e) {
      ErrorHandler.logError('Error in login: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      ErrorHandler.logError('Error in logout: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการออกจากระบบ: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response != null) {
        return User.fromMap(response);
      }
      return null;
    } catch (e) {
      ErrorHandler.logError('Error getting current user: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = await getCurrentUser();
      return user?.isAuthenticated ?? false;
    } catch (e) {
      ErrorHandler.logError('Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiService.getAllUsers();
      return response.map((userData) => User.fromMap(userData)).toList();
    } catch (e) {
      ErrorHandler.logError('Error getting all users: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้ทั้งหมด: $e');
    }
  }

  @override
  Future<User?> createUser(
    String username,
    String password,
    String role,
  ) async {
    try {
      final userData = {
        'username': username,
        'password': password,
        'role': role,
      };
      final response = await _apiService.createUser(userData);
      if (response != null) {
        return User.fromMap(response);
      }
      return null;
    } catch (e) {
      ErrorHandler.logError('Error creating user: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการสร้างผู้ใช้: $e');
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    try {
      return await _apiService.updateUser(user.toMap());
    } catch (e) {
      ErrorHandler.logError('Error updating user: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการอัปเดตผู้ใช้: $e');
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      return await _apiService.deleteUser(userId);
    } catch (e) {
      ErrorHandler.logError('Error deleting user: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการลบผู้ใช้: $e');
    }
  }

  @override
  Future<bool> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      return await _apiService.changePassword(userId, oldPassword, newPassword);
    } catch (e) {
      ErrorHandler.logError('Error changing password: $e');
      if (e is AppException) rethrow;
      throw DatabaseException('เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน: $e');
    }
  }
}
