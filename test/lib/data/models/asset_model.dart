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
  final String uid;
  @override
  final String department;
  @override
  final String date;

  AssetModel({
    required this.id,
    required this.category,
    required this.status,
    required this.brand,
    required this.uid,
    required this.department,
    required this.date,
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? '',
      brand: map['brand'] ?? '',
      uid: map['uid'] ?? '',
      department: map['department'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'status': status,
      'brand': brand,
      'uid': uid,
      'department': department,
      'date': date,
    };
  }
}
