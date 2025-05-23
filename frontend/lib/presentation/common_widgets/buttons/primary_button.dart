import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;
  final IconData? icon;
  final bool isDarkWhenPressed; // เพิ่มตัวเลือกสำหรับการเปลี่ยนสีเมื่อกด

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
    this.isDarkWhenPressed = false,
    // ค่าเริ่มต้นเป็น false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          // ถ้ากำลังกด และต้องการให้มืดตอนกด
          if (isDarkWhenPressed && states.contains(WidgetState.pressed)) {
            return Colors.grey; // เปลี่ยนสีเป็นเทาเมื่อกด
          }
          return color; // ใช้สีที่กำหนด หรือค่าเริ่มต้น
        }),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      child:
          isLoading
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Loading...'),
                ],
              )
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                  Text(text),
                ],
              ),
    );
  }
}
