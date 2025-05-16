import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/reports_bloc.dart';
import '../widgets/report_chart.dart';
import 'package:rfid_project/domain/usecases/assets/get_assets_usecase.dart';
import 'package:rfid_project/core/di/dependency_injection.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedIndex = 3; // Index for the Reports tab
  late ReportsBloc _reportsBloc;

  @override
  void initState() {
    super.initState();
    // สร้าง ReportsBloc ในกรณีที่ยังไม่ได้ลงทะเบียนใน DI
    _reportsBloc = ReportsBloc(DependencyInjection.get<GetAssetsUseCase>());

    // โหลดข้อมูลรายงาน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportsBloc.loadReportData();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/reports', '/export'][index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportsBloc>.value(
      value: _reportsBloc,
      child: ScreenContainer(
        appBar: AppBar(
          title: const Text('Asset Reports'),
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        child: Consumer<ReportsBloc>(
          builder: (context, bloc, child) {
            if (bloc.status == ReportsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (bloc.status == ReportsStatus.error) {
              return Center(child: Text('Error: ${bloc.errorMessage}'));
            } else if (bloc.assets.isEmpty) {
              return const Center(
                child: Text(
                  'No asset data available for reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Type Selector - ปรับใหม่ให้เป็น ChoiceChip แทน SegmentedButton
                      _buildReportTypeSelectorChips(bloc),

                      // Main Chart
                      SizedBox(
                        height: 350, // เพิ่มความสูงจาก 300 เป็น 350
                        child: ReportChart(bloc: bloc),
                      ),

                      // Asset Distribution Table
                      _buildDistributionTable(bloc),

                      // เพิ่มพื้นที่ว่างด้านล่าง
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // สร้าง ChoiceChip สำหรับเลือกประเภทรายงาน
  Widget _buildReportTypeSelectorChips(ReportsBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Center(
              child: Text(
                'Group by',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Category'),
                selected: bloc.selectedReportType == 'category',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('category');
                },
                avatar: const Icon(Icons.category, size: 18),
                backgroundColor: Colors.purple.withAlpha(30),
                selectedColor: Colors.purple,
                labelStyle: TextStyle(
                  color:
                      bloc.selectedReportType == 'category'
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Status'),
                selected: bloc.selectedReportType == 'status',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('status');
                },
                avatar: const Icon(Icons.check_circle_outline, size: 18),
                backgroundColor: Colors.purple.withAlpha(30),
                selectedColor: Colors.purple,
                labelStyle: TextStyle(
                  color:
                      bloc.selectedReportType == 'status'
                          ? Colors.white
                          : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Department'),
                selected: bloc.selectedReportType == 'department',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('department');
                },
                avatar: const Icon(Icons.business, size: 18),
                backgroundColor: Colors.purple.withAlpha(30),
                selectedColor: Colors.purple,
                labelStyle: TextStyle(
                  color:
                      bloc.selectedReportType == 'department'
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionTable(ReportsBloc bloc) {
    Map<String, int> data;
    String title;

    switch (bloc.selectedReportType) {
      case 'category':
        data = bloc.categoryStats;
        title = 'Assets by Category';
        break;
      case 'status':
        data = bloc.statusStats;
        title = 'Assets by Status';
        break;
      case 'department':
        data = bloc.currentLocationStats;
        title = 'Assets by Department';
        break;
      default:
        data = bloc.categoryStats;
        title = 'Assets by Category';
    }

    // Sort data by count (descending)
    List<MapEntry<String, int>> sortedEntries =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, top: 16.0, left: 4.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 24), // เพิ่มระยะห่างด้านล่าง
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Count',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Percentage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Data rows
              ...sortedEntries.map((entry) {
                final percentage = (entry.value / bloc.assets.length * 100)
                    .toStringAsFixed(1);

                // ตัดชื่อให้สั้นลงถ้ายาวเกิน
                String name = entry.key;
                if (name.length > 20) {
                  name = '${name.substring(0, 17)}...';
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8, // ลดจาก 10 เหลือ 8
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                          ), // ลดจาก 14 เป็น 13
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 13,
                          ), // ลดจาก 14 เป็น 13
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 13,
                          ), // ลดจาก 14 เป็น 13
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
