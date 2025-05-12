import '../../../domain/repositories/asset_repository.dart';

class GetRandomUidUseCase {
  final AssetRepository _assetRepository;

  GetRandomUidUseCase(this._assetRepository);

  // สุ่ม UID จากฐานข้อมูลที่มีอยู่จริง
  Future<String?> execute() async {
    try {
      // เรียกใช้เมธอดจาก repository เพื่อสุ่ม UID
      return await _assetRepository.getRandomUid();
    } catch (e) {
      // จัดการข้อผิดพลาดที่อาจเกิดขึ้น
      throw Exception('Failed to get random UID: ${e.toString()}');
    }
  }
}
