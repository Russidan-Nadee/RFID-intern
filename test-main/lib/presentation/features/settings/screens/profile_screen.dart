// lib/presentation/features/settings/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // เพิ่ม ProfileService
  final _profileService = ProfileService();

  // Controllers สำหรับช่องกรอกข้อมูล - เริ่มต้นเป็นค่าว่าง
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;

  // ซ่อน/แสดงรหัสผ่าน
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // กำหนด controller เป็นค่าว่าง
    _nameController = TextEditingController();
    _emailController = TextEditingController(
      text: 'example@email.com',
    ); // เก็บอีเมลไว้เพื่อใช้ในการแสดง Avatar
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดโทนสีหลักเหมือน Dashboard
    final primaryColor = const Color(0xFF6A5ACD); // สีม่วงสไลวันเดอร์
    final backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // บันทึกข้อมูลชื่อผู้ใช้
              _profileService.saveUserName(
                _nameController.text.isNotEmpty
                    ? _nameController.text
                    : 'Example User',
              );

              // แสดงข้อความแจ้งเตือน
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
              );

              // กลับไปหน้าก่อนหน้า
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปโปรไฟล์
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryColor,
                    child: Text(
                      _emailController.text.isNotEmpty
                          ? _emailController.text[0].toLowerCase()
                          : 'e',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(Icons.camera_alt, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ฟอร์มข้อมูลโปรไฟล์
            _buildFormField(
              label: 'Name',
              controller: _nameController,
              hintText: 'Example User',
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'E-mail address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'example@email.com',
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'User name',
              controller: _usernameController,
              hintText: 'example_user',
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            _buildFormField(
              label: 'Phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: 'Example: +66 812345678',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: const Color(0xFF6A5ACD)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
