import '../../domain/entities/random_asset_info.dart';

class RandomAssetInfoModel extends RandomAssetInfo {
  RandomAssetInfoModel({
    required String id,
    required String uid,
    required String category,
    required String brand,
    required String department,
    required String date,
    required String status,
  }) : super(
         id: id,
         uid: uid,
         category: category,
         brand: brand,
         department: department,
         date: date,
         status: status,
       );

  factory RandomAssetInfoModel.fromJson(Map<String, dynamic> json) {
    return RandomAssetInfoModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      department: json['department'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'category': category,
      'brand': brand,
      'department': department,
      'date': date,
      'status': status,
    };
  }
}
