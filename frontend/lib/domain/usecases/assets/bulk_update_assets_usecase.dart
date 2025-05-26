import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/services/error_handler.dart';
import '../../../domain/repositories/asset_repository.dart';

/// UseCase สำหรับ bulk update สถานะสินทรัพย์หลายรายการ
class BulkUpdateAssetsUseCase {
  final AssetRepository repository;

  BulkUpdateAssetsUseCase(this.repository);

  /// Bulk update สถานะจาก Available เป็น Checked
  ///
  /// [tagIds] รายการ tagId ที่ต้องการอัปเดต (สูงสุด 30 รายการ)
  /// [lastScannedBy] ชื่อผู้ที่ทำการอัปเดต
  ///
  /// Returns BulkUpdateResult พร้อมข้อมูลผลลัพธ์
  Future<BulkUpdateResult> execute(
    List<String> tagIds, {
    String? lastScannedBy,
  }) async {
    try {
      // Validation
      if (tagIds.isEmpty) {
        throw ValidationException('กรุณาเลือกรายการที่ต้องการอัปเดต');
      }

      if (tagIds.length > 30) {
        throw ValidationException('สามารถอัปเดตได้สูงสุด 30 รายการต่อครั้ง');
      }

      // กรองเฉพาะ tagId ที่ถูกต้อง
      final validTagIds =
          tagIds
              .where((tagId) => tagId.trim().isNotEmpty)
              .map((tagId) => tagId.trim())
              .toSet()
              .toList();

      if (validTagIds.isEmpty) {
        throw ValidationException('ไม่พบรายการที่ถูกต้องสำหรับการอัปเดต');
      }

      ErrorHandler.logError(
        'BulkUpdateAssetsUseCase - executing with ${validTagIds.length} valid tagIds',
      );

      // เรียก repository เพื่อ bulk update
      final success = await repository.bulkUpdateAssetStatusToChecked(
        validTagIds,
        lastScannedBy: lastScannedBy ?? 'User',
      );

      if (!success) {
        throw DatabaseException('ไม่สามารถอัปเดตสถานะได้');
      }

      return BulkUpdateResult.success(
        successCount: validTagIds.length,
        totalRequested: tagIds.length,
        processedTagIds: validTagIds,
      );
    } catch (e) {
      ErrorHandler.logError('Error in BulkUpdateAssetsUseCase: $e');

      // ส่งต่อ custom exceptions
      if (e is AppException) rethrow;

      // แปลงข้อผิดพลาดทั่วไปเป็น Exception ที่เหมาะสม
      throw DatabaseException('เกิดข้อผิดพลาดในการอัปเดตสินทรัพย์: $e');
    }
  }
}

/// คลาสสำหรับเก็บผลลัพธ์การ bulk update
class BulkUpdateResult {
  final bool success;
  final int successCount;
  final int totalRequested;
  final List<String> processedTagIds;
  final String? errorMessage;
  final DateTime timestamp;

  BulkUpdateResult({
    required this.success,
    required this.successCount,
    required this.totalRequested,
    required this.processedTagIds,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// สร้าง result สำหรับกรณีสำเร็จ
  factory BulkUpdateResult.success({
    required int successCount,
    required int totalRequested,
    required List<String> processedTagIds,
  }) {
    return BulkUpdateResult(
      success: true,
      successCount: successCount,
      totalRequested: totalRequested,
      processedTagIds: processedTagIds,
    );
  }

  /// สร้าง result สำหรับกรณีล้มเหลว
  factory BulkUpdateResult.failure({
    required String errorMessage,
    int successCount = 0,
    int totalRequested = 0,
    List<String> processedTagIds = const [],
  }) {
    return BulkUpdateResult(
      success: false,
      successCount: successCount,
      totalRequested: totalRequested,
      processedTagIds: processedTagIds,
      errorMessage: errorMessage,
    );
  }

  /// ข้อความสรุปผลลัพธ์
  String get summaryMessage {
    if (!success) {
      return errorMessage ?? 'เกิดข้อผิดพลาดในการอัปเดต';
    }

    if (successCount == totalRequested) {
      return 'อัปเดตสำเร็จทั้งหมด $successCount รายการ';
    } else {
      return 'อัปเดตสำเร็จ $successCount จาก $totalRequested รายการ';
    }
  }

  /// เปอร์เซ็นต์ความสำเร็จ
  double get successPercentage {
    if (totalRequested == 0) return 0.0;
    return (successCount / totalRequested) * 100;
  }
}
