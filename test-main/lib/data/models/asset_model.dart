import '../../domain/entities/asset.dart';

class AssetModel implements Asset {
  @override
  final String id;
  @override
  final String category;
  @override
  final String status;
  @override
  final String brand;
  @override
  final String uid; // คงเดิมเพื่อไม่ให้กระทบกับอินเทอร์เฟส Asset แต่เข้าใจว่านี่คือ tagId
  @override
  final String department;
  @override
  final String date;

  AssetModel({
    required this.id,
    required this.category,
    required this.status,
    required this.brand,
    required this.uid, // ในแอปยังคงเรียก uid แต่เข้าใจว่านี่คือ tagId
    required this.department,
    required this.date,
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    // ใช้ .toString() เพื่อแปลงทุกค่าเป็น String
    return AssetModel(
      id: map['id']?.toString() ?? map['itemId']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      brand: map['brand']?.toString() ?? map['itemName']?.toString() ?? '',
      uid:
          map['tagId']?.toString() ??
          map['epc']?.toString() ??
          '', // เปลี่ยนจาก guid เป็น tagId
      department:
          map['department']?.toString() ??
          map['currentLocation']?.toString() ??
          '',
      date: map['date']?.toString() ?? map['lastScanTime']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': id,
      'category': category,
      'status': status,
      'brand': brand,
      'itemName': brand,
      'tagId': uid, // เปลี่ยนจาก uid/guid เป็น tagId
      'epc': uid,
      'department': department,
      'currentLocation': department,
      'date': date,
      'lastScanTime': date,
    };
  }
}
