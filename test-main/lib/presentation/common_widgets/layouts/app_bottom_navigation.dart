import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/navigation_constants.dart';
import '../../../core/services/auth_service.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // กรองรายการ navigation items ตาม permissions
        final List<BottomNavigationBarItem> visibleItems = [];
        final List<int> originalIndices = [];

        for (int i = 0; i < NavigationConstants.bottomNavItems.length; i++) {
          final item = NavigationConstants.bottomNavItems[i];

          // ตรวจสอบสิทธิ์สำหรับแต่ละ tab
          bool canAccess = true;

          // ถ้าเป็น Export tab (index 4) ต้องเช็ค permission
          if (i == 4) {
            // Export tab
            canAccess = authService.canExportData;
          }

          if (canAccess) {
            visibleItems.add(item);
            originalIndices.add(i);
          }
        }

        // คำนวณ currentIndex ใหม่สำหรับ items ที่แสดง
        int adjustedCurrentIndex = 0;
        if (originalIndices.contains(currentIndex)) {
          adjustedCurrentIndex = originalIndices.indexOf(currentIndex);
        }

        return BottomNavigationBar(
          currentIndex: adjustedCurrentIndex,
          onTap: (int index) {
            // แปลง index กลับเป็น original index
            if (index < originalIndices.length) {
              final originalIndex = originalIndices[index];
              onTap(originalIndex);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: visibleItems,
        );
      },
    );
  }
}
