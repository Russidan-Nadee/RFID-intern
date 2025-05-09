// ไฟล์นี้มีบริการช่วยในการนำทางระหว่างหน้าจอต่างๆ ในแอป

import 'package:flutter/material.dart';
// นำเข้าค่าคงที่เกี่ยวกับการนำทาง เช่น เส้นทางของแต่ละแท็บ
import '../constants/navigation_constants.dart';

// คลาสบริการนำทาง - รวมฟังก์ชันช่วยในการเปลี่ยนหน้าจอทั้งหมด
class NavigationService {
  /// นำทางไปยังแท็บตามลำดับที่ระบุจากแถบนำทางด้านล่าง
  /// ตัวอย่าง: แท็บที่ 0 = หน้าหลัก, แท็บที่ 1 = หน้าค้นหา เป็นต้น
  static void navigateToTabByIndex(BuildContext context, int index) {
    // ตรวจสอบว่าตำแหน่งแท็บอยู่ในช่วงที่ถูกต้องหรือไม่
    if (index < 0 || index >= NavigationConstants.tabRoutes.length) return;

    // ดึงเส้นทางของแท็บที่ต้องการและนำทางไปยังเส้นทางนั้น
    final route = NavigationConstants.tabRoutes[index];
    Navigator.pushNamed(context, route);
  }

  /// นำทางไปยังหน้าจอใดๆ ตามชื่อเส้นทางที่ระบุ
  /// โดยเพิ่มหน้าใหม่ทับหน้าเดิม (สามารถกดปุ่มย้อนกลับได้)
  static void navigateToRoute(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// แทนที่หน้าจอปัจจุบันด้วยหน้าจอใหม่ตามเส้นทางที่ระบุ
  /// ใช้เมื่อไม่ต้องการให้กลับมาหน้าเดิมได้ด้วยปุ่มย้อนกลับ
  static void replaceWithRoute(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  /// นำทางกลับไปยังหน้าหลักและลบประวัติการนำทางทั้งหมด
  /// เหมือนการเริ่มต้นใหม่ของแอป ใช้เมื่อล็อกเอาท์หรือต้องการรีเซ็ตการนำทาง
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      NavigationConstants.tabRoutes[0], // ใช้เส้นทางของแท็บแรก (หน้าหลัก)
      (route) => false, // ลบทุกเส้นทางก่อนหน้านี้ออกจากประวัติ
    );
  }
}
