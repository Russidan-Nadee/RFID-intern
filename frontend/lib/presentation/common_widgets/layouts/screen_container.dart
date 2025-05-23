// ไฟล์ lib/presentation/common_widgets/layouts/screen_container.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool enableGradientBackground;
  final bool addSafeAreaPadding;
  final EdgeInsets contentPadding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color statusBarColor; // เพิ่มพารามิเตอร์สำหรับสี StatusBar โดยเฉพาะ

  const ScreenContainer({
    Key? key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.enableGradientBackground = false,
    this.addSafeAreaPadding = true,
    this.contentPadding = EdgeInsets.zero,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.statusBarColor = const Color(0xFFE0E0E0), // สีเทาอ่อนเป็นค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // กำหนดสี StatusBar ทันที
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor, // สีพื้นหลังของ StatusBar
        statusBarIconBrightness:
            statusBarColor.computeLuminance() > 0.5
                ? Brightness
                    .dark // ไอคอนสีดำถ้าพื้นหลังสว่าง
                : Brightness.light, // ไอคอนสีขาวถ้าพื้นหลังมืด
        systemNavigationBarColor:
            backgroundColor ?? Colors.white, // สีของแถบนำทางด้านล่าง (ถ้ามี)
      ),
    );

    // สีพื้นหลังหลักของทั้งแอพ
    final Color mainBackgroundColor = backgroundColor ?? Colors.white;

    // สร้าง AppBar ใหม่
    final PreferredSizeWidget? modifiedAppBar =
        appBar != null
            ? _createStylizedAppBar(
              appBar!,
              context,
              bottomNavigationBar != null,
              mainBackgroundColor,
            )
            : null;

    return Scaffold(
      appBar: modifiedAppBar,
      body: _buildStylizedBody(context, mainBackgroundColor),
      bottomNavigationBar:
          bottomNavigationBar != null
              ? _buildStylizedNavBar(
                bottomNavigationBar!,
                context,
                mainBackgroundColor,
              )
              : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: mainBackgroundColor,
      extendBody: true,
    );
  }

  // สร้าง body ที่ใช้สีพื้นหลังเดียวกัน
  Widget _buildStylizedBody(BuildContext context, Color backgroundColor) {
    Widget content = child;

    // เพิ่ม padding ถ้าต้องการ
    if (contentPadding != EdgeInsets.zero) {
      content = Padding(padding: contentPadding, child: content);
    }

    // เพิ่ม SafeArea ถ้าต้องการ
    if (addSafeAreaPadding) {
      content = SafeArea(child: content);
    }

    // ถ้าต้องการ gradient ยังใช้ได้ แต่ส่วนใหญ่จะไม่ได้ใช้ในกรณีนี้
    if (enableGradientBackground) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withAlpha(50),
              backgroundColor,
            ],
          ),
        ),
        child: content,
      );
    }

    return content;
  }

  // สร้าง AppBar ที่ใช้สีพื้นหลังเดียวกับทั้งแอพ
  PreferredSizeWidget _createStylizedAppBar(
    PreferredSizeWidget originalAppBar,
    BuildContext context,
    bool hasNavBar,
    Color backgroundColor,
  ) {
    if (originalAppBar is AppBar) {
      // ใช้สีหลักของแอพสำหรับข้อความและไอคอน
      final Color titleColor = Theme.of(context).primaryColor;

      final String title =
          originalAppBar.title is Text
              ? (originalAppBar.title as Text).data ?? 'RFID Asset'
              : 'RFID Asset';

      return AppBar(
        automaticallyImplyLeading:
            hasNavBar ? false : originalAppBar.automaticallyImplyLeading,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: titleColor, // ใช้สีหลักของแอพ
          ),
        ),
        centerTitle: false, // จัดชื่อชิดซ้าย
        backgroundColor: backgroundColor, // ใช้สีพื้นหลังเดียวกับทั้งแอพ
        elevation: 0, // ไม่มีเงา
        actions: originalAppBar.actions,
        iconTheme: IconThemeData(
          color: titleColor,
        ), // ไอคอนใช้สีเดียวกับข้อความ
        flexibleSpace: originalAppBar.flexibleSpace,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: backgroundColor, // ไม่มีเส้นคั่น ใช้สีเดียวกับพื้นหลัง
            height: 1,
          ),
        ),
        // ไม่กำหนด systemOverlayStyle ที่นี่ เพราะเราใช้ SystemChrome.setSystemUIOverlayStyle แล้ว
      );
    }
    return originalAppBar;
  }

  // สร้าง Navigation Bar ที่ใช้สีพื้นหลังเดียวกับทั้งแอพ
  Widget _buildStylizedNavBar(
    Widget originalNavBar,
    BuildContext context,
    Color backgroundColor,
  ) {
    if (originalNavBar is BottomNavigationBar) {
      final Color selectedItemColor =
          originalNavBar.selectedItemColor ?? Theme.of(context).primaryColor;

      return BottomNavigationBar(
        items: originalNavBar.items,
        currentIndex: originalNavBar.currentIndex,
        onTap: originalNavBar.onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedItemColor, // คงสีเดิมสำหรับไอคอนที่เลือก
        unselectedItemColor: Colors.grey, // ไอคอนที่ไม่ได้เลือกเป็นสีเทา
        backgroundColor: backgroundColor, // ใช้สีพื้นหลังเดียวกับทั้งแอพ
        elevation: 0, // ไม่มีเงา
        showSelectedLabels: true,
        showUnselectedLabels: true,
      );
    }
    return originalNavBar;
  }
}
