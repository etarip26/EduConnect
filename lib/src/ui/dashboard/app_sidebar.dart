import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/widgets/app_avatar.dart';
import 'package:test_app/src/ui/notifications/notifications_page.dart';

class AppSidebar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const AppSidebar({
    Key? key,
    required this.currentIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.instance<AuthService>();
    final isAdmin = auth.role == "admin";

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo.shade700,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo.shade700, Colors.indigo.shade500],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(radius: 28, name: auth.user?.name),
                const SizedBox(height: 12),
                Text(
                  auth.user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.role?.toUpperCase() ?? 'GUEST',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          _sidebarItem(
            context,
            index: 0,
            label: 'Home',
            icon: Icons.home_rounded,
            isActive: currentIndex == 0,
            onTap: () => _navigateTo(context, 0),
          ),
          _sidebarItem(
            context,
            index: 1,
            label: 'Search',
            icon: Icons.search_rounded,
            isActive: currentIndex == 1,
            onTap: () => _navigateTo(context, 1),
          ),
          _sidebarItem(
            context,
            index: 2,
            label: 'Chat',
            icon: Icons.chat_rounded,
            isActive: currentIndex == 2,
            onTap: () => _navigateTo(context, 2),
          ),
          _sidebarItem(
            context,
            index: 3,
            label: 'Tuition',
            icon: Icons.school_rounded,
            isActive: currentIndex == 3,
            onTap: () => _navigateTo(context, 3),
          ),
          if (!isAdmin)
            _sidebarItem(
              context,
              index: 4,
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              isActive: currentIndex == 4,
              onTap: () => _navigateTo(context, 4),
            )
          else
            _sidebarItem(
              context,
              index: 4,
              label: 'Admin Panel',
              icon: Icons.admin_panel_settings_rounded,
              isActive: currentIndex == 4,
              onTap: () => _navigateTo(context, 4),
            ),

          const Divider(indent: 20, endIndent: 20),

          // Additional Menu
          _sidebarItem(
            context,
            index: -1,
            label: 'About Us',
            icon: Icons.info_rounded,
            onTap: () => _showAboutUs(context),
          ),
          _sidebarItem(
            context,
            index: -2,
            label: 'Notifications',
            icon: Icons.notifications_rounded,
            onTap: () => _navigateTo(context, -2),
          ),
          _sidebarItem(
            context,
            index: -3,
            label: 'Reviews & Ratings',
            icon: Icons.star_rounded,
            onTap: () => _navigateTo(context, -3),
          ),

          const Divider(indent: 20, endIndent: 20),

          // Bottom Menu
          _sidebarItem(
            context,
            index: -4,
            label: 'Settings',
            icon: Icons.settings_rounded,
            onTap: () => _navigateTo(context, -4),
          ),
          _sidebarItem(
            context,
            index: -5,
            label: 'Help & Support',
            icon: Icons.help_rounded,
            onTap: () => _navigateTo(context, -5),
          ),
          _sidebarItem(
            context,
            index: -6,
            label: 'Contact Us',
            icon: Icons.mail_rounded,
            onTap: () => _navigateTo(context, -6),
          ),

          const Divider(indent: 20, endIndent: 20),

          _sidebarItem(
            context,
            index: -7,
            label: 'Logout',
            icon: Icons.logout_rounded,
            onTap: () => _logout(context),
            isDestructive: true,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.red
        : isActive
        ? Colors.indigo
        : Colors.grey.shade700;

    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: isActive
          ? Colors.indigo.withAlpha((0.1 * 255).round())
          : null,
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, int index) {
    if (index >= 0) {
      Navigator.pop(context);
      onTabChanged(index);
    } else if (index == -2) {
      // Notifications
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      );
    } else if (index == -3) {
      // Reviews & Ratings
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reviews & Ratings coming soon')),
        );
      });
    } else if (index == -4) {
      // Settings
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings coming soon')));
      });
    } else if (index == -5) {
      // Help & Support
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help & Support coming soon')),
        );
      });
    } else if (index == -6) {
      // Contact Us
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 200), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact us at support@tutorapp.com')),
        );
      });
    }
  }

  void _showAboutUs(BuildContext context) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('About EduConnect'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EduConnect',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Your trusted platform for connecting students with qualified tutors.',
                ),
                SizedBox(height: 12),
                Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Developed with ❤️ for education',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    });
  }

  void _logout(BuildContext context) {
    // Close drawer first
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final auth = GetIt.instance<AuthService>();

                  // Perform logout
                  await auth.logout();

                  // Close the confirmation dialog
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  // Small delay to ensure everything is cleared
                  await Future.delayed(const Duration(milliseconds: 200));

                  // Navigate to login page and clear navigation stack
                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false, // Remove all previous routes
                    );
                  }
                } catch (e) {
                  print("Logout error: $e");
                  // Close dialog on error
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  // Still try to navigate
                  if (context.mounted) {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    });
  }
}
