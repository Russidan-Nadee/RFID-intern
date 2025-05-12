import 'package:flutter/material.dart';
import '../../../../data/datasources/local/mock_rfid_service.dart';

class MockModeSelector extends StatelessWidget {
  final MockMode currentMode;
  final Function(MockMode) onModeChanged;

  const MockModeSelector({
    Key? key,
    required this.currentMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select RFID Mock Mode:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),

        // แต่ละโหมด
        _buildModeOption(context, MockMode.normal, 'Normal (Random)'),
        _buildModeOption(context, MockMode.found, 'Always Found'),
        _buildModeOption(context, MockMode.notFound, 'Always Not Found'),
        _buildModeOption(context, MockMode.scanFailed, 'Always Scan Failed'),
      ],
    );
  }

  Widget _buildModeOption(BuildContext context, MockMode mode, String label) {
    return RadioListTile<MockMode>(
      title: Text(label),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          onModeChanged(value);
        }
      },
      activeColor: Theme.of(context).primaryColor,
      dense: true,
    );
  }
}
