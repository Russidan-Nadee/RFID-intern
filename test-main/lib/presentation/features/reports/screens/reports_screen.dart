import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/reports_bloc.dart';
import '../widgets/report_chart.dart';
import '../widgets/report_stats_card.dart';
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
        appBar: AppBar(title: const Text('Asset Reports')),
        bottomNavigationBar: AppBottomNavigation(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        child: SafeArea(
          // เพิ่ม SafeArea เพื่อป้องกันเนื้อหาล้นออกนอกพื้นที่ปลอดภัย
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
                  // เพิ่ม Padding เพื่อให้เนื้อหาอยู่ในขอบที่เหมาะสม
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Report Type Selector - ปรับใหม่ให้เป็น ChoiceChip แทน SegmentedButton
                        _buildReportTypeSelectorChips(bloc),

                        // Summary Stats Cards
                        _buildSummaryStats(bloc),

                        // Main Chart
                        ReportChart(bloc: bloc),

                        // Asset Distribution Table
                        _buildDistributionTable(bloc),

                        // เพิ่มพื้นที่ว่างด้านล่าง
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // เปลี่ยนจาก SegmentedButton เป็น ChoiceChip แทน (เพื่อความเข้ากันได้ที่ดีกว่า)
  Widget _buildReportTypeSelectorChips(ReportsBloc bloc) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group by:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(
                label: const Text('Category'),
                selected: bloc.selectedReportType == 'category',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('category');
                },
                avatar: const Icon(Icons.category, size: 18),
              ),
              ChoiceChip(
                label: const Text('Status'),
                selected: bloc.selectedReportType == 'status',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('status');
                },
                avatar: const Icon(Icons.check_circle_outline, size: 18),
              ),
              ChoiceChip(
                label: const Text('Department'),
                selected: bloc.selectedReportType == 'department',
                onSelected: (selected) {
                  if (selected) bloc.setReportType('department');
                },
                avatar: const Icon(Icons.business, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(ReportsBloc bloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ReportStatsCard(
                  title: 'Total Assets',
                  value: bloc.assets.length.toString(),
                  icon: Icons.inventory_2,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ReportStatsCard(
                  title: 'Categories',
                  value: bloc.categoryStats.length.toString(),
                  icon: Icons.category,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReportStatsCard(
                  title: 'Statuses',
                  value: bloc.statusStats.length.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ReportStatsCard(
                  title: 'Departments',
                  value: bloc.departmentStats.length.toString(),
                  icon: Icons.business,
                  color: Colors.purple,
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
        data = bloc.departmentStats;
        title = 'Assets by Department';
        break;
      default:
        data = bloc.categoryStats;
        title = 'Assets by Category';
    }

    // Sort data by count (descending)
    List<MapEntry<String, int>> sortedEntries =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children: [
                      _buildTableHeader('Name'),
                      _buildTableHeader('Count'),
                      _buildTableHeader('Percentage'),
                    ],
                  ),
                  ...sortedEntries.map((entry) {
                    final percentage = (entry.value / bloc.assets.length * 100)
                        .toStringAsFixed(1);
                    return TableRow(
                      children: [
                        _buildTableCell(entry.key),
                        _buildTableCell(entry.value.toString()),
                        _buildTableCell('$percentage%'),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(text)),
      ),
    );
  }
}
