// lib/core/utils/icon_utils.dart
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

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'checked in':
      return Icons.check_circle_outline;
    case 'available':
      return Icons.inventory_2;
    case 'in use':
      return Icons.people_outline;
    case 'maintenance':
      return Icons.build_outlined;
    default:
      return Icons.info_outline;
  }
}
