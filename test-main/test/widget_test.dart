import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfid_project/main.dart'; // ใช้ main.dart ในการเริ่มต้นแอป

void main() {
  testWidgets('MainScreen BottomNavigationBar test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // เรียก MyApp เพื่อเริ่มแอป

    // ตรวจสอบว่าเรามี 5 ปุ่มใน BottomNavigationBar
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.table_chart), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.byIcon(Icons.import_export), findsOneWidget);

    // ตรวจสอบว่าเริ่มต้นอยู่ที่หน้า Home
    expect(
      find.text('Dashboard'),
      findsOneWidget,
    ); // ปรับข้อความตามที่มีใน HomeScreen

    // ทดสอบการกดปุ่ม View
    await tester.tap(find.byIcon(Icons.table_chart));
    await tester.pumpAndSettle(); // รอให้การเปลี่ยนหน้าเสร็จสมบูรณ์
    expect(
      find.text('View Assets Page'),
      findsOneWidget,
    ); // เปลี่ยนข้อความตามหน้าที่แสดง

    // ทดสอบการกดปุ่ม Search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(
      find.text('Search Assets Page'),
      findsOneWidget,
    ); // เปลี่ยนข้อความตามหน้าที่แสดง

    // ทดสอบการกดปุ่ม Scan
    await tester.tap(find.byIcon(Icons.qr_code_scanner));
    await tester.pumpAndSettle();
    expect(
      find.text('Scan RFID Page'),
      findsOneWidget,
    ); // เปลี่ยนข้อความตามหน้าที่แสดง

    // ทดสอบการกดปุ่ม Export
    await tester.tap(find.byIcon(Icons.import_export));
    await tester.pumpAndSettle();
    expect(
      find.text('Export function is not ready yet.'),
      findsOneWidget,
    ); // เปลี่ยนข้อความตามหน้าที่แสดง
  });
}
