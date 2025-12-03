import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/services/storage_service.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_stats_card.dart';
import 'widgets/admin_users_table.dart';
import 'widgets/admin_sidebar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final authService = GetIt.I<AuthService>();
  final storageService = GetIt.I<StorageService>();
  late Future<Map<String, dynamic>> dashboardStats;
  late Future<List<Map<String, dynamic>>> usersList;

  @override
  void initState() {
    super.initState();
    dashboardStats = _fetchDashboardStats();
    usersList = _fetchUsers();
  }

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    try {
      final token = await storageService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching stats: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      final token = await storageService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/users?limit=50'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List users = data['data'] ?? [];
        return users.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Row(
        children: [
          // Sidebar
          if (!isSmallScreen)
            SizedBox(width: 280, child: AdminSidebar(onLogout: _handleLogout)),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  AdminHeader(onLogout: _handleLogout),
                  // Dashboard Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Dashboard Overview',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 32),

                        // Stats Cards Grid
                        FutureBuilder<Map<String, dynamic>>(
                          future: dashboardStats,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00D4FF),
                                ),
                              );
                            }

                            final stats = snapshot.data ?? {};
                            final users =
                                stats['users'] as Map<String, dynamic>? ?? {};
                            final tuitions =
                                stats['tuitions'] as Map<String, dynamic>? ??
                                {};

                            return GridView.count(
                              crossAxisCount: isSmallScreen ? 1 : 3,
                              childAspectRatio: isSmallScreen ? 1.2 : 1.0,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 24,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                AdminStatsCard(
                                  icon: Icons.people,
                                  title: 'Total Users',
                                  value: '${users['totalUsers'] ?? 0}',
                                  subtitle:
                                      '${users['activeUsers'] ?? 0} active',
                                  color: const Color(0xFF00D4FF),
                                  delay: 0,
                                ),
                                AdminStatsCard(
                                  icon: Icons.school,
                                  title: 'Students',
                                  value: '${users['students'] ?? 0}',
                                  subtitle:
                                      '${users['verifiedUsers'] ?? 0} verified',
                                  color: const Color(0xFF00D4FF),
                                  delay: 100,
                                ),
                                AdminStatsCard(
                                  icon: Icons.person_pin,
                                  title: 'Teachers',
                                  value: '${users['teachers'] ?? 0}',
                                  subtitle: 'Active instructors',
                                  color: const Color(0xFF00D4FF),
                                  delay: 200,
                                ),
                                AdminStatsCard(
                                  icon: Icons.book,
                                  title: 'Active Tuitions',
                                  value: '${tuitions['activeTuitions'] ?? 0}',
                                  subtitle:
                                      '${tuitions['pendingTuitions'] ?? 0} pending',
                                  color: const Color(0xFFFF6B9D),
                                  delay: 300,
                                ),
                                AdminStatsCard(
                                  icon: Icons.admin_panel_settings,
                                  title: 'Admins',
                                  value: '${users['admins'] ?? 0}',
                                  subtitle: 'Platform admins',
                                  color: const Color(0xFF00D4FF),
                                  delay: 400,
                                ),
                                AdminStatsCard(
                                  icon: Icons.block,
                                  title: 'Suspended',
                                  value: '${users['suspendedUsers'] ?? 0}',
                                  subtitle: 'Blocked accounts',
                                  color: const Color(0xFFFF6B9D),
                                  delay: 500,
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 48),

                        // Users Table
                        Text(
                          'User Management',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: usersList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00D4FF),
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No users found',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }

                            return AdminUsersTable(
                              users: snapshot.data ?? [],
                              onRefresh: () {
                                setState(() {
                                  usersList = _fetchUsers();
                                  dashboardStats = _fetchDashboardStats();
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
