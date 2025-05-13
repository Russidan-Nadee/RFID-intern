import 'package:flutter/material.dart';
import '../blocs/reports_bloc.dart';
import 'package:fl_chart/fl_chart.dart'; // ต้องเพิ่ม dependency: fl_chart ในไฟล์ pubspec.yaml

class ReportChart extends StatelessWidget {
  final ReportsBloc bloc;

  const ReportChart({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // เลือกข้อมูลตามประเภทรายงานที่เลือก
    Map<String, int> data;
    String title;

    switch (bloc.selectedReportType) {
      case 'category':
        data = bloc.categoryStats;
        title = 'Asset Distribution by Category';
        break;
      case 'status':
        data = bloc.statusStats;
        title = 'Asset Distribution by Status';
        break;
      case 'department':
        data = bloc.departmentStats;
        title = 'Asset Distribution by Department';
        break;
      default:
        data = bloc.categoryStats;
        title = 'Asset Distribution by Category';
    }

    // จัดเรียงข้อมูลและเตรียมสำหรับแสดงในกราฟ
    List<MapEntry<String, int>> sortedData =
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sections: _createPieSections(sortedData, bloc.assets.length),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _createLegendItems(sortedData),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(
    List<MapEntry<String, int>> data,
    int totalAssets,
  ) {
    // สีประจำส่วนต่างๆ ของกราฟ
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    return List.generate(data.length > 10 ? 10 : data.length, (i) {
      final isOthers = i == 9 && data.length > 10;
      String title;
      double value;

      if (isOthers) {
        // รวมข้อมูลที่เหลือเป็น "Others"
        int othersValue = 0;
        for (int j = 9; j < data.length; j++) {
          othersValue += data[j].value;
        }
        title = 'Others';
        value = othersValue / totalAssets * 100;
      } else {
        title = data[i].key;
        value = data[i].value / totalAssets * 100;
      }

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _createLegendItems(List<MapEntry<String, int>> data) {
    // สีประจำส่วนต่างๆ ของกราฟ
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    return List.generate(data.length > 10 ? 10 : data.length, (i) {
      final isOthers = i == 9 && data.length > 10;
      String title;

      if (isOthers) {
        title = 'Others';
      } else {
        title = data[i].key;
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 16, height: 16, color: colors[i % colors.length]),
          const SizedBox(width: 4),
          Text(title),
        ],
      );
    });
  }
}
