enum UserRole { admin, manager, staff, viewer }

extension UserRoleExtension on UserRole {
  // แปลงเป็น string แสดงผล
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
      case UserRole.viewer:
        return 'Viewer';
    }
  }

  // ตรวจสอบระดับสิทธิ์
  bool get canManageUsers => this == UserRole.admin;

  bool get canManageSystem => this == UserRole.admin;

  bool get canBulkUpdate => this == UserRole.admin || this == UserRole.manager;

  bool get canApproveOperations =>
      this == UserRole.admin || this == UserRole.manager;

  bool get canUpdateAssets =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.staff;

  bool get canViewReports => true; // ทุกคนดู reports ได้

  bool get canExportData => this != UserRole.viewer;

  // ตรวจสอบว่ามีสิทธิ์สูงกว่าหรือเท่ากับระดับที่กำหนด
  bool hasPermissionLevel(UserRole requiredLevel) {
    const hierarchy = [
      UserRole.viewer,
      UserRole.staff,
      UserRole.manager,
      UserRole.admin,
    ];
    return hierarchy.indexOf(this) >= hierarchy.indexOf(requiredLevel);
  }

  // แปลงจาก string
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'staff':
        return UserRole.staff;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer; // default เป็น viewer
    }
  }
}
