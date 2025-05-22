import 'user_role.dart';

class User {
  final String id;
  final String username;
  final UserRole role;
  final bool isAuthenticated;
  final DateTime? lastLoginTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.role,
    this.isAuthenticated = false,
    this.lastLoginTime,
    required this.createdAt,
    required this.updatedAt,
  });

  // สร้าง User จาก Map (สำหรับ API response)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      role: UserRole.fromString(map['role']?.toString() ?? 'viewer'),
      isAuthenticated: map['isAuthenticated'] ?? false,
      lastLoginTime:
          map['lastLoginTime'] != null
              ? DateTime.parse(map['lastLoginTime'])
              : null,
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'])
              : DateTime.now(),
    );
  }

  // แปลงเป็น Map (สำหรับ API request)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'role': role.name,
      'isAuthenticated': isAuthenticated,
      'lastLoginTime': lastLoginTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // สร้างสำเนาพร้อมการเปลี่ยนแปลงบางฟิลด์
  User copyWith({
    String? id,
    String? username,
    UserRole? role,
    bool? isAuthenticated,
    DateTime? lastLoginTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // สร้าง User ที่ login แล้ว
  User login() {
    return copyWith(
      isAuthenticated: true,
      lastLoginTime: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // สร้าง User ที่ logout แล้ว
  User logout() {
    return copyWith(isAuthenticated: false, updatedAt: DateTime.now());
  }

  // ตรวจสอบสิทธิ์ต่างๆ
  bool get canManageUsers => role.canManageUsers;
  bool get canManageSystem => role.canManageSystem;
  bool get canBulkUpdate => role.canBulkUpdate;
  bool get canUpdateAssets => role.canUpdateAssets;
  bool get canViewReports => role.canViewReports;
  bool get canExportData => role.canExportData;

  // ตรวจสอบว่ามีสิทธิ์ในระดับที่กำหนด
  bool hasPermissionLevel(UserRole requiredLevel) {
    return role.hasPermissionLevel(requiredLevel);
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: ${role.displayName}, authenticated: $isAuthenticated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
