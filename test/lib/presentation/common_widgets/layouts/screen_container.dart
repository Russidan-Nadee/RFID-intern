// ไฟล์ lib/presentation/common_widgets/layouts/screen_container.dart
import 'package:flutter/material.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const ScreenContainer({
    Key? key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // สร้าง AppBar ใหม่ที่ไม่มีปุ่มย้อนกลับเสมอ
    final modifiedAppBar =
        appBar != null ? _createAppBarWithoutBackButton(appBar!) : null;

    return Scaffold(
      appBar: modifiedAppBar,
      body: child,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  // สร้าง AppBar ใหม่โดยไม่มีปุ่มย้อนกลับในทุกหน้า
  PreferredSizeWidget _createAppBarWithoutBackButton(
    PreferredSizeWidget originalAppBar,
  ) {
    if (originalAppBar is AppBar) {
      return AppBar(
        automaticallyImplyLeading: false, // ปิดการแสดงปุ่มย้อนกลับในทุกหน้า
        title: originalAppBar.title,
        actions: originalAppBar.actions,
        backgroundColor: originalAppBar.backgroundColor,
        elevation: originalAppBar.elevation,
        centerTitle: originalAppBar.centerTitle,
        bottom: originalAppBar.bottom,
      );
    }
    return originalAppBar;
  }
}
