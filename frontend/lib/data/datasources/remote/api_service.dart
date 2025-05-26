import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<bool> updateUserRole(String userId, String newRole) async {
    final url = '$baseUrl/auth/users/$userId/role';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode({'role': newRole}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Failed to update user role';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error updating user role: $e', url);
    }
  }

  Future<bool> canUpdateUserRole(
    String currentUserRole,
    String targetUserRole,
    String newRole,
  ) async {
    final url = '$baseUrl/auth/users/can-update-role';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode({
          'currentUserRole': currentUserRole,
          'targetUserRole': targetUserRole,
          'newRole': newRole,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['canUpdate'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      ErrorHandler.logError('Error checking role update permission: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = '$baseUrl/auth/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Store token for future requests
        _authToken = jsonData['token'];
        return jsonData['data'];
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Login failed';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error during login: $e', url);
    }
  }

  Future<void> logout() async {
    final url = '$baseUrl/auth/logout';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _authToken = null; // Clear stored token
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Logout failed';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      // For logout, we might want to clear token even if request fails
      _authToken = null;
      throw FetchDataException('Error during logout: $e', url);
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final url = '$baseUrl/auth/me';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else if (response.statusCode == 401) {
        _authToken = null; // Clear invalid token
        return null;
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Failed to get user';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error getting current user: $e', url);
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final url = '$baseUrl/auth/users';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Failed to get users';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error getting users: $e', url);
    }
  }

  Future<Map<String, dynamic>?> createUser(
    Map<String, dynamic> userData,
  ) async {
    final url = '$baseUrl/auth/users';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Failed to create user';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error creating user: $e', url);
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData) async {
    final url = '$baseUrl/auth/users/${userData['id']}';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error updating user: $e', url);
    }
  }

  Future<bool> deleteUser(String userId) async {
    final url = '$baseUrl/auth/users/$userId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error deleting user: $e', url);
    }
  }

  Future<bool> changePassword(
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    final url = '$baseUrl/auth/users/$userId/password';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error changing password: $e', url);
    }
  }

  // Private helper methods
  String? _authToken;

  Map<String, String> _getAuthHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Add method to set token (for session restoration)
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Add method to get current token
  String? getAuthToken() {
    return _authToken;
  }

  // ดึงข้อมูลสินทรัพย์ทั้งหมด
  Future<List<Map<String, dynamic>>> getAssets() async {
    final url = '$baseUrl/assets';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Network error: $e', url);
    }
  }

  // ดึงข้อมูลสินทรัพย์ตาม tagId
  Future<Map<String, dynamic>?> getAssetBytagId(String tagId) async {
    final url = '$baseUrl/assets/$tagId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else if (response.statusCode == 404) {
        return null; // ไม่พบสินทรัพย์ คืนค่า null
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error getting asset by tagId: $e', url);
    }
  }

  // เพิ่มสินทรัพย์ใหม่
  Future<void> insertAsset(Map<String, dynamic> assetData) async {
    final url = '$baseUrl/assets';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assetData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error adding asset: $e', url);
    }
  }

  // ลบสินทรัพย์
  Future<void> deleteAsset(String uid) async {
    final url = '$baseUrl/assets/$uid';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error deleting asset: $e', url);
    }
  }

  // ลบสินทรัพย์ทั้งหมด
  Future<void> deleteAllAssets() async {
    final url = '$baseUrl/assets/all';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error deleting all assets: $e', url);
    }
  }

  // ดึงข้อมูลหมวดหมู่ทั้งหมด
  Future<List<String>> getCategories() async {
    final url = '$baseUrl/categories';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> categoriesData = jsonData['data'];
        return categoriesData
            .map((category) => category['name'].toString())
            .toList();
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error loading categories: $e', url);
    }
  }

  // เพิ่มหมวดหมู่ใหม่
  Future<void> addCategory(String name) async {
    final url = '$baseUrl/categories';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error adding category: $e', url);
    }
  }

  // อัพเดตหมวดหมู่
  Future<void> updateCategory(String oldName, String newName) async {
    final url = '$baseUrl/categories/$oldName';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error updating category: $e', url);
    }
  }

  // ลบหมวดหมู่
  Future<void> deleteCategory(String name) async {
    final url = '$baseUrl/categories/$name';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error deleting category: $e', url);
    }
  }

  // ดึงข้อมูลแผนกทั้งหมด
  Future<List<String>> getDepartments() async {
    final url = '$baseUrl/departments';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> departmentsData = jsonData['data'];
        return departmentsData.map((dept) => dept['name'].toString()).toList();
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error loading departments: $e', url);
    }
  }

  // เพิ่มแผนกใหม่
  Future<void> addDepartment(String name) async {
    final url = '$baseUrl/departments';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error adding department: $e', url);
    }
  }

  // อัพเดตแผนก
  Future<void> updateDepartment(String oldName, String newName) async {
    final url = '$baseUrl/departments/$oldName';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error updating department: $e', url);
    }
  }

  // ลบแผนก
  Future<void> deleteDepartment(String name) async {
    final url = '$baseUrl/departments/$name';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode != 200) {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error deleting department: $e', url);
    }
  }

  // สแกน RFID จากอุปกรณ์
  Future<String?> scanRfidtag() async {
    final url = '$baseUrl/rfid/scan';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['tagId'];
      } else {
        return null;
      }
    } catch (e) {
      // ในกรณีนี้เราแค่ return null เพื่อให้ทำงานเหมือนเดิม
      // แต่ยังคงบันทึก error เพื่อประโยชน์ในการตรวจสอบ
      ErrorHandler.logError('Error scanning RFID: $e');
      return null;
    }
  }

  // เพิ่มเมธอดตรวจสอบ EPC
  Future<bool> checkEpcExists(String epc) async {
    final url = '$baseUrl/assets/check-epc?epc=$epc';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['exists'] ?? false;
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException('Error checking EPC: $e', url);
    }
  }

  Future<bool> createAsset(Map<String, dynamic> assetData) async {
    final url = '$baseUrl/assets';
    try {
      ErrorHandler.logError('Sending data to API: ${json.encode(assetData)}');
      ErrorHandler.logError('API URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode(assetData),
      );

      ErrorHandler.logError('Status code: ${response.statusCode}');
      ErrorHandler.logError('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      ErrorHandler.logError('Error in API: $e');
      throw FetchDataException('Error creating asset: $e', url);
    }
  }

  Future<bool> updateAssetStatusToChecked(
    String tagId, {
    String? lastScannedBy,
  }) async {
    final url = '$baseUrl/assets/$tagId/status/checked';
    try {
      // สร้าง request body และตรวจสอบ lastScannedBy อย่างรัดกุม
      final Map<String, dynamic> requestBody = {};

      // เพิ่ม lastScannedBy เข้าไปในคำขอเสมอ
      requestBody['lastScannedBy'] =
          (lastScannedBy != null && lastScannedBy.isNotEmpty)
              ? lastScannedBy
              : 'User';

      // บันทึก log สำหรับตรวจสอบ
      ErrorHandler.logError(
        'Sending request with lastScannedBy: ${requestBody['lastScannedBy']}',
      );

      final response = await http.put(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        ErrorHandler.logError('Update successful: ${jsonData['data']}');
        return jsonData['success'] ?? false;
      } else {
        // บันทึก log แสดงข้อผิดพลาดอย่างละเอียด
        ErrorHandler.logError('Error updating status: ${response.statusCode}');
        ErrorHandler.logError('Response body: ${response.body}');

        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      ErrorHandler.logError('Error in updateAssetStatusToChecked: $e');
      throw DatabaseException('Error updating status: $e');
    }
  }

  // เพิ่ม method ใหม่ในคลาส ApiService (เพิ่มหลัง updateAssetStatusToChecked method)

  Future<Map<String, dynamic>?> bulkUpdateAssetStatusToChecked(
    List<String> tagIds, {
    String? lastScannedBy,
  }) async {
    final url = '$baseUrl/assets/bulk/status/checked';
    try {
      // Validation
      if (tagIds.isEmpty) {
        throw ValidationException('กรุณาเลือกรายการที่ต้องการอัปเดต');
      }

      if (tagIds.length > 30) {
        throw ValidationException('สามารถอัปเดตได้สูงสุด 30 รายการต่อครั้ง');
      }

      // สร้าง request body
      final Map<String, dynamic> requestBody = {
        'tagIds': tagIds,
        'lastScannedBy':
            (lastScannedBy != null && lastScannedBy.isNotEmpty)
                ? lastScannedBy
                : 'User',
      };

      // บันทึก log สำหรับตรวจสอบ
      ErrorHandler.logError(
        'Bulk update request: ${tagIds.length} items, scanner: ${requestBody['lastScannedBy']}',
      );

      final response = await http.put(
        Uri.parse(url),
        headers: _getAuthHeaders(),
        body: json.encode(requestBody),
      );

      ErrorHandler.logError('Bulk update response: ${response.statusCode}');
      ErrorHandler.logError('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        ErrorHandler.logError('Bulk update successful: ${jsonData['data']}');
        return jsonData;
      } else {
        // บันทึก log แสดงข้อผิดพลาดอย่างละเอียด
        ErrorHandler.logError(
          'Error bulk updating status: ${response.statusCode}',
        );
        ErrorHandler.logError('Error response body: ${response.body}');

        // ใช้ ErrorHandler ในการสร้าง exception ที่เหมาะสม
        final responseBody = json.decode(response.body);
        final message = responseBody['message'] ?? 'Unknown error';
        throw ErrorHandler.handleApiError(response.statusCode, message, url);
      }
    } on http.ClientException {
      throw FetchDataException('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์', url);
    } catch (e) {
      if (e is AppException) rethrow;
      ErrorHandler.logError('Error in bulkUpdateAssetStatusToChecked: $e');
      throw DatabaseException('Error bulk updating status: $e');
    }
  }
}
