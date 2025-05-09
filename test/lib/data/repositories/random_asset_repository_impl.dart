import 'dart:math';

import '../../domain/entities/random_asset_info.dart';
import '../../domain/repositories/random_asset_repository.dart';

class RandomAssetRepositoryImpl implements RandomAssetRepository {
  final Random _random = Random();

  // รายการหมวดหมู่ที่เป็นไปได้
  final List<String> _categories = ['laptop', 'mouse', 'monitor', 'phone'];

  // รายการแบรนด์ที่เป็นไปได้
  final List<String> _brands = [
    'Dell',
    'HP',
    'Logitech',
    'Samsung',
    'Apple',
    'Lenovo',
    'Microsoft',
    'Acer',
    'Razer',
    'Xiaomi',
    'Oppo',
    'Asus',
  ];

  // รายการแผนกที่เป็นไปได้
  final List<String> _departments = ['it', 'admin', 'hr', 'finance'];

  @override
  Future<RandomAssetInfo> generateRandomAssetInfo() async {
    // สุ่ม ID (10 ตัวอักษรตัวใหญ่และตัวเลข)
    final String id = _generateRandomHexString(10);

    // สุ่ม UID (10 ตัวอักษรตัวใหญ่และตัวเลข)
    final String uid = _generateRandomHexString(10);

    // สุ่มหมวดหมู่
    final String category = _categories[_random.nextInt(_categories.length)];

    // สุ่มแบรนด์
    final String brand = _brands[_random.nextInt(_brands.length)];

    // สุ่มแผนก
    final String department =
        _departments[_random.nextInt(_departments.length)];

    // วันที่ปัจจุบัน
    final String date = DateTime.now().toString().split(' ')[0];

    // สถานะเริ่มต้น
    const String status = 'Available';

    return RandomAssetInfo(
      id: id,
      uid: uid,
      category: category,
      brand: brand,
      department: department,
      date: date,
      status: status,
    );
  }

  // สร้างสตริงแบบสุ่มที่มีความยาวที่กำหนด
  String _generateRandomHexString(int length) {
    const chars = '0123456789ABCDEF';
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }
}
