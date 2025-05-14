import 'package:flutter/material.dart';
import '../blocs/reports_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อกราฟ
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // กราฟวงกลม
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: PieChart(
                  PieChartData(
                    sections: _createPieSections(
                      sortedData,
                      bloc.assets.length,
                    ),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    centerSpaceColor: Colors.white,
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
              ),
            ),

            // คำอธิบายสัญลักษณ์
            _buildColorIndicators(sortedData),
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
      Colors.blue, // สีฟ้า
      Colors.green, // สีเขียว
      Colors.orange, // สีส้ม
      Colors.purple, // สีม่วง
      Colors.red, // สีแดง
    ];

    // จำกัดจำนวนส่วนที่แสดงให้ไม่เกิน 5 ส่วน
    final int maxSections = data.length > 5 ? 5 : data.length;

    return List.generate(maxSections, (i) {
      final isOthers = i == 4 && data.length > 5;
      double value;

      if (isOthers) {
        // รวมข้อมูลที่เหลือเป็น "Others"
        int othersValue = 0;
        for (int j = 4; j < data.length; j++) {
          othersValue += data[j].value;
        }
        value = othersValue / totalAssets * 100;
      } else {
        value = data[i].value / totalAssets * 100;
      }

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: 90, // ลดขนาดรัศมีจาก 100 เป็น 90
        titleStyle: const TextStyle(
          fontSize: 12, // ลดขนาดตัวอักษรจาก 14 เป็น 12
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
        ),
        titlePositionPercentageOffset:
            0.6, // ปรับตำแหน่งให้เข้าไปในวงกลมมากขึ้น
      );
    });
  }

  Widget _buildColorIndicators(List<MapEntry<String, int>> data) {
    // สีประจำส่วนต่างๆ ของกราฟ
    final List<Color> colors = [
      Colors.blue, // สีฟ้า
      Colors.green, // สีเขียว
      Colors.orange, // สีส้ม
      Colors.purple, // สีม่วง
      Colors.red, // สีแดง
    ];

    // จำกัดจำนวนส่วนที่แสดงให้ไม่เกิน 5 ส่วน
    final int maxSections = data.length > 5 ? 5 : data.length;

    return Wrap(
      spacing: 6, // ลดจาก 8
      runSpacing: 2, // ลดจาก 4
      alignment: WrapAlignment.center,
      children: List.generate(maxSections, (i) {
        final isOthers = i == 4 && data.length > 5;
        String title = isOthers ? 'Others' : data[i].key;

        // ตัดชื่อให้สั้นลงถ้ายาวเกิน
        if (title.length > 12) {
          title = '${title.substring(0, 9)}...';
        }

        return Container(
          margin: const EdgeInsets.only(right: 2, bottom: 2), // ลดระยะห่าง
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10, // ลดจาก 12
                height: 10, // ลดจาก 12
                decoration: BoxDecoration(color: colors[i % colors.length]),
              ),
              const SizedBox(width: 2), // ลดจาก 4
              Text(
                title,
                style: const TextStyle(fontSize: 10), // ลดจาก 12
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }
}
