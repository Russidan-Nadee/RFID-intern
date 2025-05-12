// lib/presentation/features/export/screens/export_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../blocs/export_bloc.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../features/main/blocs/navigation_bloc.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final List<String> availableColumns = [
    'ID',
    'Category',
    'Brand',
    'Status',
    'Date',
    'Department',
    'UID',
    'Last Scan',
  ];

  void _onNavigationTap(int index) {
    // ดึง NavigationBloc จาก Provider
    final navigationBloc = Provider.of<NavigationBloc>(context, listen: false);

    // อัปเดต index ใน NavigationBloc
    navigationBloc.setCurrentIndex(index);

    // ใช้ NavigationService เพื่อไปยังหน้าที่ต้องการ
    NavigationService.navigateToTabByIndex(context, index);
  }

  @override
  Widget build(BuildContext context) {
    // เพิ่มการอ่านค่า currentIndex จาก NavigationBloc
    final navigationBloc = Provider.of<NavigationBloc>(context);
    final currentIndex = navigationBloc.currentIndex;

    return ScreenContainer(
      appBar: AppBar(title: const Text('Export Assets Data'), elevation: 0),
      // เพิ่ม bottomNavigationBar เข้าไป
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: currentIndex,
        onTap: _onNavigationTap,
      ),
      child: Consumer<ExportBloc>(
        builder: (context, bloc, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select columns to export',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: availableColumns.length,
                  itemBuilder: (context, index) {
                    final column = availableColumns[index];
                    final isSelected = bloc.selectedColumns.contains(column);

                    return CheckboxListTile(
                      title: Text(column),
                      value: isSelected,
                      onChanged: (value) {
                        if (value != null) {
                          bloc.toggleColumnSelection(column);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  text: 'Export Data',
                  icon: Icons.download,
                  onPressed: () {}, // ปุ่มกดไม่ได้ตามที่ต้องการ
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
