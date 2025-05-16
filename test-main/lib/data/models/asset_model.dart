import '../../domain/entities/asset.dart';

class AssetModel implements Asset {
  @override
  final String id;
  @override
  final String tagId;
  @override
  final String epc;
  @override
  final String itemId;
  @override
  final String itemName;
  @override
  final String category;
  @override
  final String status;
  @override
  final String tagType;
  @override
  final String saleDate;
  @override
  final String frequency;
  @override
  final String currentLocation;
  @override
  final String zone;
  @override
  final String lastScanTime;
  @override
  final String lastScannedBy;
  @override
  final String batteryLevel;
  @override
  final String batchNumber;
  @override
  final String manufacturingDate;
  @override
  final String expiryDate;
  @override
  final String value;

  AssetModel({
    required this.id,
    required this.tagId,
    required this.epc,
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.status,
    required this.tagType,
    required this.saleDate,
    required this.frequency,
    required this.currentLocation,
    required this.zone,
    required this.lastScanTime,
    required this.lastScannedBy,
    required this.batteryLevel,
    required this.batchNumber,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.value,
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id']?.toString() ?? '',
      tagId: map['tagId']?.toString() ?? '',
      epc: map['epc']?.toString() ?? '',
      itemId: map['itemId']?.toString() ?? '',
      itemName: map['itemName']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      tagType: map['tagType']?.toString() ?? '',
      saleDate: map['saleDate']?.toString() ?? '',
      frequency: map['frequency']?.toString() ?? '',
      currentLocation: map['currentLocation']?.toString() ?? '',
      zone: map['zone']?.toString() ?? '',
      lastScanTime: map['lastScanTime']?.toString() ?? '',
      lastScannedBy: map['lastScannedBy']?.toString() ?? '',
      batteryLevel: map['batteryLevel']?.toString() ?? '',
      batchNumber: map['batchNumber']?.toString() ?? '',
      manufacturingDate: map['manufacturingDate']?.toString() ?? '',
      expiryDate: map['expiryDate']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagId': tagId,
      'epc': epc,
      'itemId': itemId,
      'itemName': itemName,
      'category': category,
      'status': status,
      'tagType': tagType,
      'saleDate': saleDate,
      'frequency': frequency,
      'currentLocation': currentLocation,
      'zone': zone,
      'lastScanTime': lastScanTime,
      'lastScannedBy': lastScannedBy,
      'batteryLevel': batteryLevel,
      'batchNumber': batchNumber,
      'manufacturingDate': manufacturingDate,
      'expiryDate': expiryDate,
      'value': value,
    };
  }
}
