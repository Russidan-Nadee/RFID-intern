// ไฟล์นี้เก็บค่าคงที่ที่ใช้ทั่วทั้งแอพและเปลี่ยนแปลงน้อย

class AppConstants {
  // ค่าคงที่พื้นฐานของแอพ
  static const int splashDuration = 2; // จำนวนวินาทีที่แสดงหน้าเริ่มต้น
  static const int maxAssetNameLength = 100; // ความยาวสูงสุดของชื่อสินทรัพย์

  // ค่าสถานะมาตรฐาน (แก้ไขน้อย)
  static const String statusAvailable = 'Available'; // สถานะพร้อมใช้งาน
  static const String statusCheckedIn = 'Checked In'; // สถานะนำเข้าแล้ว

  // ค่าเริ่มต้นสำหรับหมวดหมู่สินทรัพย์ (ใช้เมื่อยังไม่มีข้อมูลในฐานข้อมูล)
  static const List<String> defaultAssetCategories = [
    'Laptop', // โน้ตบุ๊ก
    'Monitor', // จอภาพ
    'Mouse', // เมาส์
    'Phone', // โทรศัพท์
    'Other', // อื่นๆ
  ];

  // ค่าเริ่มต้นสำหรับแผนก (ใช้เมื่อยังไม่มีข้อมูลในฐานข้อมูล)
  static const List<String> defaultDepartments = [
    'IT',
    'HR',
    'Finance',
    'Admin',
  ];

  // ข้อจำกัดของชื่อหมวดหมู่และแผนก
  static const int maxCategoryNameLength = 50; // ความยาวสูงสุดของชื่อหมวดหมู่
  static const int maxDepartmentNameLength = 50; // ความยาวสูงสุดของชื่อแผนก
}
