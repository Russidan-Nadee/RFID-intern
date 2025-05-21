// test-main/lib/data/datasources/remote/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/exceptions/app_exceptions.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;

  // ดึงข้อมูลสินทรัพย์ทั้งหมด
  Future<List<Map<String, dynamic>>> getAssets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assets'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw NetworkException(
          message: 'Failed to load assets: ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      // ตรวจสอบว่าเป็น NetworkException อยู่แล้วหรือไม่
      if (e is NetworkException) {
        throw e;
      }
      // ถ้าเป็น Exception อื่นๆ ให้ห่อด้วย NetworkException
      throw NetworkException(
        message: 'Network error: $e',
        url: '$baseUrl/assets',
      );
    }
  }

  // ดึงข้อมูลสินทรัพย์ตาม tagId (เปลี่ยนจาก uid)
  Future<Map<String, dynamic>?> getAssetBytagId(String tagId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assets/$tagId'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else if (response.statusCode == 404) {
        // ส่งคืน null เมื่อไม่พบสินทรัพย์เหมือนเดิมเพื่อคงการทำงานเดิม
        return null;
      } else {
        throw NetworkException(
          message: 'Error: ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets/$tagId',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Network error: $e',
        url: '$baseUrl/assets/$tagId',
      );
    }
  }

  // อัพเดตสถานะของสินทรัพย์
  Future<bool> updateAssetStatus(String uid, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assets/status/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw NetworkException(
          message: 'Error updating status: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets/status/$uid',
          requestMethod: 'PUT',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      // คงการทำงานเดิมโดยส่งคืน false แต่ยัง throw exception ด้วย
      print('DEBUG - Error updating status: $e');
      throw NetworkException(
        message: 'Error updating status: $e',
        url: '$baseUrl/assets/status/$uid',
      );
    }
  }

  // เพิ่มสินทรัพย์ใหม่
  Future<void> insertAsset(Map<String, dynamic> assetData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assetData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw NetworkException(
          message: 'Error adding asset: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets',
          requestMethod: 'POST',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error adding asset: $e',
        url: '$baseUrl/assets',
      );
    }
  }

  // ลบสินทรัพย์
  Future<void> deleteAsset(String uid) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/assets/$uid'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          message: 'Error deleting asset: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets/$uid',
          requestMethod: 'DELETE',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error deleting asset: $e',
        url: '$baseUrl/assets/$uid',
      );
    }
  }

  // ลบสินทรัพย์ทั้งหมด
  Future<void> deleteAllAssets() async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/assets/all'));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          message:
              'Error deleting all assets: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets/all',
          requestMethod: 'DELETE',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error deleting all assets: $e',
        url: '$baseUrl/assets/all',
      );
    }
  }

  // ดึงข้อมูลหมวดหมู่ทั้งหมด
  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> categoriesData = jsonData['data'];
        return categoriesData
            .map((category) => category['name'].toString())
            .toList();
      } else {
        throw NetworkException(
          message: 'Failed to load categories: ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/categories',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Network error: $e',
        url: '$baseUrl/categories',
      );
    }
  }

  // เพิ่มหมวดหมู่ใหม่
  Future<void> addCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw NetworkException(
          message: 'Error adding category: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/categories',
          requestMethod: 'POST',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error adding category: $e',
        url: '$baseUrl/categories',
      );
    }
  }

  // อัพเดตหมวดหมู่
  Future<void> updateCategory(String oldName, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$oldName'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode != 200) {
        throw NetworkException(
          message:
              'Error updating category: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/categories/$oldName',
          requestMethod: 'PUT',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error updating category: $e',
        url: '$baseUrl/categories/$oldName',
      );
    }
  }

  // ลบหมวดหมู่
  Future<void> deleteCategory(String name) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$name'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          message:
              'Error deleting category: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/categories/$name',
          requestMethod: 'DELETE',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error deleting category: $e',
        url: '$baseUrl/categories/$name',
      );
    }
  }

  // ดึงข้อมูลแผนกทั้งหมด
  Future<List<String>> getDepartments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/departments'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> departmentsData = jsonData['data'];
        return departmentsData.map((dept) => dept['name'].toString()).toList();
      } else {
        throw NetworkException(
          message: 'Failed to load departments: ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/departments',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Network error: $e',
        url: '$baseUrl/departments',
      );
    }
  }

  // เพิ่มแผนกใหม่
  Future<void> addDepartment(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/departments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw NetworkException(
          message:
              'Error adding department: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/departments',
          requestMethod: 'POST',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error adding department: $e',
        url: '$baseUrl/departments',
      );
    }
  }

  // อัพเดตแผนก
  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/departments/$oldName'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );

      if (response.statusCode != 200) {
        throw NetworkException(
          message:
              'Error updating department: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/departments/$oldName',
          requestMethod: 'PUT',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error updating department: $e',
        url: '$baseUrl/departments/$oldName',
      );
    }
  }

  // ลบแผนก
  Future<void> deleteDepartment(String name) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/departments/$name'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          message:
              'Error deleting department: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/departments/$name',
          requestMethod: 'DELETE',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Error deleting department: $e',
        url: '$baseUrl/departments/$name',
      );
    }
  }

  // สแกน RFID จากอุปกรณ์
  Future<String?> scanRfidtag() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rfid/scan'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['tagId'];
      } else {
        throw NetworkException(
          message: 'Error scanning RFID: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/rfid/scan',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      print('DEBUG - Error scanning RFID: $e');
      // ยังคงส่งคืน null เพื่อคงการทำงานเดิม
      return null;
    }
  }

  // เพิ่มเมธอดตรวจสอบ EPC
  Future<bool> checkEpcExists(String epc) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/assets/check-epc?epc=$epc'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['exists'] ?? false;
      } else {
        throw NetworkException(
          message:
              'ไม่สามารถตรวจสอบ EPC ได้: Status code ${response.statusCode}',
          statusCode: response.statusCode,
          url: '$baseUrl/api/assets/check-epc?epc=$epc',
          requestMethod: 'GET',
        );
      }
    } catch (e) {
      if (e is NetworkException) {
        throw e;
      }
      throw NetworkException(
        message: 'Network error: $e',
        url: '$baseUrl/api/assets/check-epc',
      );
    }
  }

  Future<bool> createAsset(Map<String, dynamic> assetData) async {
    try {
      print('DEBUG - Sending data to API: ${json.encode(assetData)}');
      print('DEBUG - API URL: $baseUrl/assets');

      final response = await http.post(
        Uri.parse('$baseUrl/assets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assetData),
      );

      print('DEBUG - Status code: ${response.statusCode}');
      print('DEBUG - Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw NetworkException(
          message:
              'Error creating asset: Status code ${response.statusCode}, Body: ${response.body}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets',
          requestMethod: 'POST',
        );
      }
    } catch (e) {
      print('DEBUG - Error in API: $e');
      if (e is NetworkException) {
        // คงการทำงานเดิมโดยส่งคืน false
        return false;
      }
      // คงการทำงานเดิมโดยส่งคืน false เมื่อเกิดข้อผิดพลาด
      return false;
    }
  }

  Future<bool> updateAssetStatusToChecked(
    String tagId, {
    String? lastScannedBy,
  }) async {
    try {
      // สร้าง request body และตรวจสอบ lastScannedBy อย่างรัดกุม
      final Map<String, dynamic> requestBody = {};

      // เพิ่ม lastScannedBy เข้าไปในคำขอเสมอ
      // ถ้าเป็น null หรือว่าง ให้ใช้ค่า 'User' แทน (หรือค่าอื่นที่คุณต้องการ)
      requestBody['lastScannedBy'] =
          (lastScannedBy != null && lastScannedBy.isNotEmpty)
              ? lastScannedBy
              : 'User';

      // บันทึก log สำหรับตรวจสอบ
      print(
        'DEBUG - Sending request with lastScannedBy: ${requestBody['lastScannedBy']}',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/assets/$tagId/status/checked'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('DEBUG - Update successful: ${jsonData['data']}');
        return jsonData['success'] ?? false;
      } else {
        // บันทึก log แสดงข้อผิดพลาดอย่างละเอียด
        print('DEBUG - Error updating status: ${response.statusCode}');
        print('DEBUG - Response body: ${response.body}');

        throw NetworkException(
          message:
              'Error updating asset status: Status code ${response.statusCode}, Body: ${response.body}',
          statusCode: response.statusCode,
          url: '$baseUrl/assets/$tagId/status/checked',
          requestMethod: 'PUT',
        );
      }
    } catch (e) {
      print('DEBUG - Network error in updateAssetStatusToChecked: $e');
      if (e is NetworkException) {
        // คงการทำงานเดิมโดยส่งคืน false
        return false;
      }
      // คงการทำงานเดิมโดยส่งคืน false
      return false;
    }
  }
}
