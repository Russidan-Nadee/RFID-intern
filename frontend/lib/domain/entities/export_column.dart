class ExportColumn {
  final String key; // คีย์ภายใน เช่น 'id', 'tagId'
  final String displayName; // ชื่อที่แสดงผล เช่น 'ID', 'Tag ID'
  final String group; // กลุ่ม เช่น 'ข้อมูลระบุตัวตน'
  final bool isSelected; // สถานะการเลือก

  const ExportColumn({
    required this.key,
    required this.displayName,
    required this.group,
    this.isSelected = false,
  });

  ExportColumn copyWith({bool? isSelected}) {
    return ExportColumn(
      key: key,
      displayName: displayName,
      group: group,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
