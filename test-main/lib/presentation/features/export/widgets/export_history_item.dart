import 'package:flutter/material.dart';

class ExportHistoryItem extends StatelessWidget {
  final Map<String, dynamic> exportData;
  final IconData formatIcon;
  final VoidCallback onDownload;

  const ExportHistoryItem({
    Key? key,
    required this.exportData,
    required this.formatIcon,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(formatIcon, color: Colors.blue, size: 20),
      ),
      title: Text(exportData['filename']),
      subtitle: Text(
        '${exportData['date']} • ${exportData['records']} records',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.file_download),
        onPressed: onDownload,
      ),
      onTap: () {
        // Show detailed export info
      },
    );
  }
}
