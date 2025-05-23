import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<List<User>> getAllUsers();
  Future<User?> createUser(String username, String password, String role);
  Future<bool> updateUser(User user);
  Future<bool> deleteUser(String userId);
  Future<bool> updateUserRole(String userId, String newRole);
  Future<bool> canUpdateUserRole(
    String currentUserRole,
    String targetUserRole,
    String newRole,
  );
  Future<bool> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  );
}
