// lib/presentation/features/settings/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // เพิ่ม ProfileService
  final _profileService = ProfileService();

  // ตัวแปรเก็บชื่อผู้ใช้
  late String _userName;
  // ตัวแปรเก็บอีเมล (ค่าคงที่)
  final String _userEmail = 'example@email.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // อัปเดตข้อมูลเมื่อกลับมาที่หน้านี้
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userName = _profileService.getUserName();
      if (_userName.isEmpty) {
        _userName = 'Example User';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดโทนสีหลักเหมือน Dashboard
    final primaryColor = const Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;
    final lightPrimaryColor = const Color(0xFFE6E4F4); // สีม่วงอ่อน

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: ListView(
        children: [
          // ส่วนโปรไฟล์ด้านบน
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // รูปโปรไฟล์ - ใช้ตัวอักษรแรกของอีเมลแบบไดนามิก
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primaryColor,
                  child: Text(
                    _userEmail.isNotEmpty ? _userEmail[0].toLowerCase() : '',
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                // ข้อมูลโปรไฟล์ - ใช้ชื่อจาก ProfileService
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // ปุ่มแก้ไขโปรไฟล์
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.profile).then((
                      _,
                    ) {
                      // อัปเดตชื่อผู้ใช้เมื่อกลับมาจากหน้า Edit Profile
                      setState(() {
                        _loadUserData(); // เรียกใช้ฟังก์ชันโหลดข้อมูลใหม่
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // รายการเมนูตั้งค่า
          _buildMenuItem(
            icon: Icons.favorite_border,
            title: 'Favourites',
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.download_outlined,
            title: 'Downloads',
            onTap: () {},
          ),

          _buildMenuItem(icon: Icons.language, title: 'Language', onTap: () {}),

          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Location',
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.subscriptions_outlined,
            title: 'Subscription',
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.cached,
            title: 'Clear cache',
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.history,
            title: 'Clear history',
            onTap: () {},
          ),

          // ปุ่ม Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildMenuItem(
              icon: Icons.logout,
              title: 'Log out',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: titleColor ?? Colors.black87, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
