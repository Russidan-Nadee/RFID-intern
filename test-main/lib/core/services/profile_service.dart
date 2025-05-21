class ProfileService {
  // Singleton pattern
  static final ProfileService _instance = ProfileService._internal();

  factory ProfileService() {
    return _instance;
  }

  ProfileService._internal();

  // สถานะว่ามีการตั้งค่าโปรไฟล์หรือยัง
  bool _isProfileSet = false;

  // ข้อมูลชื่อผู้ใช้ (ค่าเริ่มต้นเป็นค่าว่าง)
  String _userName = '';

  // เพิ่มฟิลด์สำหรับเก็บอีเมล
  String _userEmail = '';

  // ดึงชื่อผู้ใช้
  String getUserName() {
    // ถ้ายังไม่มีการตั้งค่า ให้ใช้ค่าตัวอย่าง
    if (!_isProfileSet || _userName.isEmpty) {
      return 'Example User';
    }
    return _userName;
  }

  // บันทึกชื่อผู้ใช้
  void saveUserName(String name) {
    _userName = name;
    _isProfileSet = true;
  }

  // ดึงอีเมลผู้ใช้
  String getUserEmail() {
    if (!_isProfileSet || _userEmail.isEmpty) {
      return 'example@email.com';
    }
    return _userEmail;
  }

  // บันทึกอีเมลผู้ใช้
  void saveUserEmail(String email) {
    _userEmail = email;
    _isProfileSet = true;
  }

  // ตรวจสอบว่ามีการตั้งค่าโปรไฟล์แล้วหรือยัง
  bool isProfileSet() {
    return _isProfileSet;
  }

  // รีเซ็ตโปรไฟล์
  void resetProfile() {
    _userName = '';
    _userEmail = '';
    _isProfileSet = false;
  }
}
