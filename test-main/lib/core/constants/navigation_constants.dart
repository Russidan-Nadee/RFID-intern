// ไฟล์นี้เก็บค่าคงที่สำหรับการนำทางในแอพ

import 'package:flutter/material.dart';
import 'route_constants.dart'; // นำเข้าไฟล์ที่เก็บชื่อเส้นทางต่างๆ

class NavigationConstants {
  // รายการปุ่มในแถบนำทางด้านล่าง
  static const List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home), // ไอคอนบ้าน
      label: 'Home', // ข้อความแสดงหน้าหลัก
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search), // ไอคอนแว่นขยาย
      label: 'Search', // ข้อความแสดงหน้าค้นหา
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.camera_alt), // ไอคอนกล้อง
      label: 'Scan', // ข้อความแสดงหน้าสแกน
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.visibility), // ไอคอนตา
      label: 'View', // ข้อความแสดงหน้าดูรายการ
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.file_download), // ไอคอนดาวน์โหลด
      label: 'Export', // ข้อความแสดงหน้าส่งออกข้อมูล
    ),
  ];

  // รายการเส้นทางที่สัมพันธ์กับแต่ละปุ่มในแถบนำทางด้านล่าง
  static const List<String> tabRoutes = [
    RouteConstants.home, // เส้นทางไปหน้าหลัก
    RouteConstants.searchAssets, // เส้นทางไปหน้าค้นหาสินทรัพย์
    RouteConstants.scanRfid, // เส้นทางไปหน้าสแกน RFID
    RouteConstants.viewAssets, // เส้นทางไปหน้าดูรายการสินทรัพย์
    RouteConstants.export, // เส้นทางไปหน้าส่งออกข้อมูล
  ];
}
