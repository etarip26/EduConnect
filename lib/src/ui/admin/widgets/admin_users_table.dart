import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/storage_service.dart';
import 'dart:convert';

class AdminUsersTable extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final VoidCallback onRefresh;

  const AdminUsersTable({
    Key? key,
    required this.users,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AdminUsersTable> createState() => _AdminUsersTableState();
}

class _AdminUsersTableState extends State<AdminUsersTable> {
  final authService = GetIt.I<AuthService>();
  final storageService = GetIt.I<StorageService>();
  late List<Map<String, dynamic>> displayUsers;
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    displayUsers = List.from(widget.users);
  }

  void _sortUsers(String field) {
    setState(() {
      if (_sortBy == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = field;
        _sortAscending = false;
      }

      displayUsers.sort((a, b) {
        var aVal = a[field];
        var bVal = b[field];

        if (_sortAscending) {
          return aVal.toString().compareTo(bVal.toString());
        } else {
          return bVal.toString().compareTo(aVal.toString());
        }
      });
    });
  }

  Future<void> _suspendUser(String userId) async {
    try {
      final token = await storageService.getToken();
      final response = await http.patch(
        Uri.parse('http://localhost:5000/api/admin/users/$userId/suspend'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': 'Admin action'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User suspended successfully'),
            backgroundColor: Color(0xFFFF1744),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      print('Error suspending user: $e');
    }
  }

  Future<void> _activateUser(String userId) async {
    try {
      final token = await storageService.getToken();
      final response = await http.patch(
        Uri.parse('http://localhost:5000/api/admin/users/$userId/activate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User activated successfully'),
            backgroundColor: Color(0xFF00D4FF),
          ),
        );
        widget.onRefresh();
      }
    } catch (e) {
      print('Error activating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A2332).withOpacity(0.6),
            const Color(0xFF0F1419).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
            (states) => const Color(0xFF1A2332).withOpacity(0.8),
          ),
          dataRowColor: MaterialStateColor.resolveWith(
            (states) => const Color(0xFF1A2332).withOpacity(0.3),
          ),
          headingRowHeight: 56,
          dataRowHeight: 56,
          columns: [
            DataColumn(
              label: _buildHeader('Name'),
              onSort: (index, ascending) => _sortUsers('name'),
            ),
            DataColumn(
              label: _buildHeader('Email'),
              onSort: (index, ascending) => _sortUsers('email'),
            ),
            DataColumn(
              label: _buildHeader('Role'),
              onSort: (index, ascending) => _sortUsers('role'),
            ),
            DataColumn(
              label: _buildHeader('Status'),
              onSort: (index, ascending) => _sortUsers('isSuspended'),
            ),
            DataColumn(
              label: _buildHeader('Joined'),
              onSort: (index, ascending) => _sortUsers('createdAt'),
            ),
            DataColumn(label: _buildHeader('Actions')),
          ],
          rows: displayUsers
              .map(
                (user) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        user['name'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        user['email'] ?? 'N/A',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    DataCell(_buildRoleBadge(user['role'])),
                    DataCell(_buildStatusBadge(user['isSuspended'])),
                    DataCell(
                      Text(
                        _formatDate(user['createdAt']),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          _buildActionButton(
                            icon: user['isSuspended']
                                ? Icons.check_circle
                                : Icons.block,
                            label: user['isSuspended'] ? 'Activate' : 'Suspend',
                            color: user['isSuspended']
                                ? const Color(0xFF00D4FF)
                                : const Color(0xFFFF1744),
                            onPressed: () {
                              if (user['isSuspended']) {
                                _activateUser(user['_id']);
                              } else {
                                _suspendUser(user['_id']);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF00D4FF),
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    IconData icon;

    switch (role) {
      case 'admin':
        color = const Color(0xFF00D4FF);
        icon = Icons.admin_panel_settings;
        break;
      case 'teacher':
        color = const Color(0xFFFF6B9D);
        icon = Icons.person_pin;
        break;
      default:
        color = const Color(0xFF76FF03);
        icon = Icons.school;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            role.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isSuspended) {
    if (isSuspended) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFF1744).withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.4)),
        ),
        child: const Text(
          'SUSPENDED',
          style: TextStyle(
            color: Color(0xFFFF1744),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF76FF03).withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF76FF03).withOpacity(0.4)),
        ),
        child: const Text(
          'ACTIVE',
          style: TextStyle(
            color: Color(0xFF76FF03),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
