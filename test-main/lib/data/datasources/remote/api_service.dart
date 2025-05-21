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
        throw DatabaseException(
          'Failed to load assets: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw DatabaseException('Network error: $e');
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
        return null; // ไม่พบสินทรัพย์
      } else {
        throw DatabaseException('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw DatabaseException('Network error: $e');
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

      return response.statusCode == 200;
    } catch (e) {
      throw DatabaseException('Error updating status: $e');
    }
  }

  // เพิ่มสินทรัพย์ใหม่
  Future<void> insertAsset(Map<String, dynamic> assetData) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/assets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assetData),
      );
    } catch (e) {
      throw DatabaseException('Error adding asset: $e');
    }
  }

  // ลบสินทรัพย์
  Future<void> deleteAsset(String uid) async {
    try {
      await http.delete(Uri.parse('$baseUrl/assets/$uid'));
    } catch (e) {
      throw DatabaseException('Error deleting asset: $e');
    }
  }

  // ลบสินทรัพย์ทั้งหมด
  Future<void> deleteAllAssets() async {
    try {
      await http.delete(Uri.parse('$baseUrl/assets/all'));
    } catch (e) {
      throw DatabaseException('Error deleting all assets: $e');
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
        throw DatabaseException(
          'Failed to load categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw DatabaseException('Network error: $e');
    }
  }

  // เพิ่มหมวดหมู่ใหม่
  Future<void> addCategory(String name) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
    } catch (e) {
      throw DatabaseException('Error adding category: $e');
    }
  }

  // อัพเดตหมวดหมู่
  Future<void> updateCategory(String oldName, String newName) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/categories/$oldName'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );
    } catch (e) {
      throw DatabaseException('Error updating category: $e');
    }
  }

  // ลบหมวดหมู่
  Future<void> deleteCategory(String name) async {
    try {
      await http.delete(Uri.parse('$baseUrl/categories/$name'));
    } catch (e) {
      throw DatabaseException('Error deleting category: $e');
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
        throw DatabaseException(
          'Failed to load departments: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw DatabaseException('Network error: $e');
      // ในกรณีที่ API ยังไม่รองรับ ให้ return ค่าเริ่มต้น
      // return ['IT', 'HR', 'Admin', 'Finance'];
    }
  }

  // เพิ่มแผนกใหม่
  Future<void> addDepartment(String name) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/departments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
    } catch (e) {
      throw DatabaseException('Error adding department: $e');
    }
  }

  // อัพเดตแผนก
  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/departments/$oldName'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );
    } catch (e) {
      throw DatabaseException('Error updating department: $e');
    }
  }

  // ลบแผนก
  Future<void> deleteDepartment(String name) async {
    try {
      await http.delete(Uri.parse('$baseUrl/departments/$name'));
    } catch (e) {
      throw DatabaseException('Error deleting department: $e');
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
        return null;
      }
    } catch (e) {
      print('Error scanning RFID: $e');
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
        throw DatabaseException('ไม่สามารถตรวจสอบ EPC ได้');
      }
    } catch (e) {
      throw DatabaseException('Network error: $e');
    }
  }

  Future<bool> createAsset(Map<String, dynamic> assetData) async {
    try {
      print('Sending data to API: ${json.encode(assetData)}');
      print('API URL: $baseUrl/assets');

      final response = await http.post(
        Uri.parse('$baseUrl/assets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assetData),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error in API: $e');
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
        'Sending request with lastScannedBy: ${requestBody['lastScannedBy']}',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/assets/$tagId/status/checked'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Update successful: ${jsonData['data']}');
        return jsonData['success'] ?? false;
      } else {
        // บันทึก log แสดงข้อผิดพลาดอย่างละเอียด
        print('Error updating status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network error in updateAssetStatusToChecked: $e');
      throw DatabaseException('Error updating status: $e');
    }
  }
}
