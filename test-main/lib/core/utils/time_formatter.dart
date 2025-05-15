// lib/core/utils/time_formatter.dart
class TimeFormatter {
  /// แปลงวันที่เป็นรูปแบบข้อความ "เมื่อไม่นานมานี้", "x นาทีที่ผ่านมา" เป็นต้น
  static String timeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} วันที่ผ่านมา';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ชั่วโมงที่ผ่านมา';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} นาทีที่ผ่านมา';
      } else {
        return 'เมื่อสักครู่';
      }
    } catch (e) {
      return dateString;
    }
  }
}
