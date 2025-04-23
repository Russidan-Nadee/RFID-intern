import 'package:flutter/material.dart';
import 'package:rfid_project/pages/assets_page.dart';
import 'package:rfid_project/pages/scan_rfid_page.dart';
import 'package:rfid_project/pages/search_and_detail_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 40.0, // ขยายขนาดตัวอักษรของหัวข้อให้ใหญ่ขึ้นอีก
              fontWeight: FontWeight.bold, // เพิ่มความหนาให้ตัวอักษร
            ),
          ),
        ),
        backgroundColor: Colors.white, // สีขาวสำหรับ AppBar
        foregroundColor: Colors.blue, // สีฟ้าสำหรับข้อความใน AppBar
      ),
      body: Center(
        child: Container(
          color: Colors.white, // สีขาวสำหรับพื้นหลัง
          child: Column(
            mainAxisSize: MainAxisSize.min, // ขนาดของ Column จะปรับตามเนื้อหา
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildButton(context, 'Connect RFID Reader', ScanRFIDPage()),
              _buildButton(context, 'View Assets', AssetsPage()),
              _buildButton(context, 'Search Asset', SearchAndDetailPage()),
              _buildButton(context, 'Export Audit Data', null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Widget? page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          textStyle: TextStyle(fontSize: 20.0),
        ),
        onPressed:
            page != null
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => page),
                  );
                }
                : null, // Add functionality for Export Audit Data
        child: Text(text),
      ),
    );
  }
}
