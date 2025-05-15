import 'export_column.dart';

class ExportConfiguration {
  final List<ExportColumn> columns;
  final String format;
  final int estimatedSize;

  const ExportConfiguration({
    required this.columns,
    this.format = 'CSV',
    this.estimatedSize = 0,
  });

  List<ExportColumn> get selectedColumns =>
      columns.where((column) => column.isSelected).toList();

  ExportConfiguration copyWith({
    List<ExportColumn>? columns,
    String? format,
    int? estimatedSize,
  }) {
    return ExportConfiguration(
      columns: columns ?? this.columns,
      format: format ?? this.format,
      estimatedSize: estimatedSize ?? this.estimatedSize,
    );
  }

  // คำนวณขนาดไฟล์โดยประมาณ (KB)
  int calculateEstimatedSize(int assetCount) {
    final selectedCount = selectedColumns.length;
    final bytesPerCell = 30;
    final headerBytes = 500;
    final totalBytes =
        (assetCount * selectedCount * bytesPerCell) + headerBytes;
    return (totalBytes / 1024).ceil();
  }
}
