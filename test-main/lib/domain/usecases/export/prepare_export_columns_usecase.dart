import '../../entities/export_column.dart';

class PrepareExportColumnsUseCase {
  List<ExportColumn> execute() {
    final Map<String, String> columnsMap = {
      'id': 'ID',
      'itemId': 'Item ID',
      'tagId': 'Tag ID',
      'epc': 'EPC',
      'itemName': 'Item Name',
      'category': 'Category',
      'status': 'Status',
      'tagType': 'Tag Type',
      'value': 'Value',
      'frequency': 'Frequency',
      'currentLocation': 'Location',
      'zone': 'Zone',
      'lastScanTime': 'Last Scan Time',
      'lastScanQuantity': 'Last Scan Quantity',
      'batteryLevel': 'Battery Level',
      'batchNumber': 'Batch Number',
      'manufacturingDate': 'Manufacturing Date',
    };

    final Map<String, List<String>> columnGroups = {
      'ข้อมูลระบุตัวตน': ['id', 'itemId', 'tagId', 'epc'],
      'ข้อมูลสินค้า': ['itemName', 'category', 'status', 'value', 'tagType'],
      'ข้อมูลตำแหน่ง': ['currentLocation', 'zone'],
      'ข้อมูลเวลาและการติดตาม': ['lastScanTime', 'lastScanQuantity'],
      'ข้อมูลเทคนิค': [
        'batteryLevel',
        'batchNumber',
        'frequency',
        'manufacturingDate',
      ],
    };

    List<ExportColumn> columns = [];

    columnsMap.forEach((key, displayName) {
      String group = 'อื่นๆ';

      // หากลุ่มของคอลัมน์
      for (var entry in columnGroups.entries) {
        if (entry.value.contains(key)) {
          group = entry.key;
          break;
        }
      }

      columns.add(
        ExportColumn(
          key: key,
          displayName: displayName,
          group: group,
          isSelected: true, // เริ่มต้นเลือกทั้งหมด
        ),
      );
    });

    return columns;
  }
}
