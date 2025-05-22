import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/inputs/text_input.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/error_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Navigate to main app
        Navigator.pushReplacementNamed(context, '/');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เข้าสู่ระบบสำเร็จ ยินดีต้อนรับ ${authService.getUserName()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ErrorHandler.showError(
          context,
          authService.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(context, 'เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.security,
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RFID Asset Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'เข้าสู่ระบบเพื่อจัดการสินทรัพย์',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Username Field
                  TextInput(
                    controller: _usernameController,
                    label: 'ชื่อผู้ใช้',
                    hint: 'กรอกชื่อผู้ใช้',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกชื่อผู้ใช้';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextInput(
                    controller: _passwordController,
                    label: 'รหัสผ่าน',
                    hint: 'กรอกรหัสผ่าน',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรหัสผ่าน';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return authService.isLoading
                          ? const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          )
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleLogin(),
                              icon: const Icon(Icons.login),
                              label: const Text('เข้าสู่ระบบ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Demo Accounts Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'บัญชีทดสอบ (รหัสผ่าน: admin123)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDemoAccount('admin', 'ผู้ดูแลระบบ'),
                        _buildDemoAccount('manager1', 'ผู้จัดการ'),
                        _buildDemoAccount('staff1', 'พนักงาน'),
                        _buildDemoAccount('viewer1', 'ผู้ดู'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip Login (for development)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text(
                      'ข้ามการเข้าสู่ระบบ (สำหรับการพัฒนา)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String username, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.person, size: 16, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            '$username',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(' - $role', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
