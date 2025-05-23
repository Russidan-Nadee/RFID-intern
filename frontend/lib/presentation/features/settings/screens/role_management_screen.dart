import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/status/loading_error_widget.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/user_role.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  bool _isLoading = true;
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  String? _errorMessage;
  UserRole? _selectedRoleFilter;
  String? _expandedUserId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      _allUsers = await authService.getAllUsers();
      _applyFilter();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _applyFilter() {
    final authService = Provider.of<AuthService>(context, listen: false);

    List<User> allowedUsers = [];

    for (var user in _allUsers) {
      if (authService.isAdmin) {
        allowedUsers.add(user);
      } else if (authService.isManager) {
        if (user.role == UserRole.staff || user.role == UserRole.viewer) {
          allowedUsers.add(user);
        }
      }
    }

    if (_selectedRoleFilter != null) {
      _filteredUsers =
          allowedUsers
              .where((user) => user.role == _selectedRoleFilter)
              .toList();
    } else {
      _filteredUsers = allowedUsers;
    }
  }

  List<UserRole> _getAvailableRoles() {
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.getAvailableRolesForUser(UserRole.viewer);
  }

  Future<void> _updateUserRole(User user, UserRole newRole) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.updateUserRole(user.id, newRole);

      if (success) {
        _showSnackBar('Role updated successfully', Colors.green);
        await _loadUsers();
      } else {
        _showSnackBar('Failed to update role', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Connection failed', Colors.red);
    } finally {
      setState(() {
        _isUpdating = false;
        _expandedUserId = null;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF6A5ACD);

    return ScreenContainer(
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      child: Column(
        children: [
          // Role Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRoleChip(null, 'All', primaryColor),
                  const SizedBox(width: 8),
                  ..._getAvailableRoles().map(
                    (role) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildRoleChip(
                        role,
                        role.displayName,
                        primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(child: _buildContent(primaryColor)),
        ],
      ),
    );
  }

  Widget _buildRoleChip(UserRole? role, String label, Color primaryColor) {
    final isSelected = _selectedRoleFilter == role;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRoleFilter = selected ? role : null;
          _applyFilter();
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildContent(Color primaryColor) {
    if (_isLoading) {
      return LoadingWidget(primaryColor: primaryColor);
    }

    if (_errorMessage != null) {
      return ErrorDisplayWidget(
        errorMessage: _errorMessage!,
        onRetry: _loadUsers,
        primaryColor: primaryColor,
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedRoleFilter != null
                  ? 'No ${_selectedRoleFilter!.displayName.toLowerCase()} users found'
                  : 'No users found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildExpandableUserCard(user, primaryColor);
        },
      ),
    );
  }

  Widget _buildExpandableUserCard(User user, Color primaryColor) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isExpanded = _expandedUserId == user.id;
    final availableRoles = authService.getAvailableRolesForUser(user.role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.role),
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role: ${user.role.displayName}'),
                Text(
                  'Last login: ${_formatLastLogin(user.lastLoginTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing:
                availableRoles.isNotEmpty
                    ? AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    )
                    : null,
            onTap:
                availableRoles.isNotEmpty
                    ? () {
                      setState(() {
                        _expandedUserId = isExpanded ? null : user.id;
                      });
                    }
                    : null,
          ),

          // Expanded Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded ? null : 0,
            child:
                isExpanded
                    ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text(
                            'Change Role:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Role Selection Dropdown
                          _buildRoleDropdown(
                            user,
                            availableRoles,
                            primaryColor,
                          ),
                        ],
                      ),
                    )
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown(
    User user,
    List<UserRole> availableRoles,
    Color primaryColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: user.role,
          isExpanded: true,
          items:
              availableRoles.map((role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role.displayName),
                );
              }).toList(),
          onChanged:
              _isUpdating
                  ? null
                  : (UserRole? newRole) {
                    if (newRole != null && newRole != user.role) {
                      _showRoleChangeConfirmation(user, newRole);
                    }
                  },
        ),
      ),
    );
  }

  void _showRoleChangeConfirmation(User user, UserRole newRole) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Role Change'),
            content: Text(
              'Change ${user.username}\'s role from ${user.role.displayName} to ${newRole.displayName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateUserRole(user, newRole);
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.staff:
        return Colors.green;
      case UserRole.viewer:
        return Colors.orange;
    }
  }

  String _formatLastLogin(DateTime? lastLogin) {
    if (lastLogin == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
