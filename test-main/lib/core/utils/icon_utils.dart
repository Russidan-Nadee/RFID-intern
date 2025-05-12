import 'package:flutter/material.dart';

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'mouse':
      return Icons.mouse;
    case 'laptop':
      return Icons.laptop;
    case 'monitor':
      return Icons.desktop_windows;
    case 'phone':
      return Icons.phone_android;
    default:
      return Icons.devices_other;
  }
}
