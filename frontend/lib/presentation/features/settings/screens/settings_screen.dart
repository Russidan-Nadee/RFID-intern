import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rfid_project/domain/entities/user_role.dart';
import 'package:rfid_project/presentation/features/settings/screens/role_management_screen.dart';
import '../../../../domain/service/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6A5ACD);
    final backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final username = authService.currentUser?.username ?? 'Guest';
          final role = authService.currentUser?.role.displayName ?? 'Unknown';
          final email = '${username.toLowerCase()}@thaipatker.com';

          return ListView(
            children: [
              // ส่วนโปรไฟล์ด้านบน
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // รูปโปรไฟล์
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primaryColor,
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'G',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ข้อมูลโปรไฟล์
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$role • $email',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // รายการเมนูตั้งค่า
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  // แสดงเฉพาะ Manager และ Admin
                  if (!authService.canManageUsers) {
                    return const SizedBox.shrink(); // ซ่อน menu item
                  }

                  return _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    title: 'User Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoleManagementScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.language,
                title: 'Language',
                onTap: () {},
              ),

              _buildMenuItem(
                icon: Icons.history,
                title: 'Activity history',
                onTap: () {},
              ),

              // ปุ่ม Logout
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Log out',
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () async {
                  await authService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          );
        },
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
