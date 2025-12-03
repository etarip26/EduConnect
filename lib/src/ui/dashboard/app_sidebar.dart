import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/widgets/app_avatar.dart';

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
            label: 'Notifications',
            icon: Icons.notifications_rounded,
            onTap: () => _navigateTo(context, -1),
          ),
          _sidebarItem(
            context,
            index: -2,
            label: 'Reviews & Ratings',
            icon: Icons.star_rounded,
            onTap: () => _navigateTo(context, -2),
          ),

          const Divider(indent: 20, endIndent: 20),

          // Bottom Menu
          _sidebarItem(
            context,
            index: -3,
            label: 'Settings',
            icon: Icons.settings_rounded,
            onTap: () => _navigateTo(context, -3),
          ),
          _sidebarItem(
            context,
            index: -4,
            label: 'Help & Support',
            icon: Icons.help_rounded,
            onTap: () => _navigateTo(context, -4),
          ),
          _sidebarItem(
            context,
            index: -5,
            label: 'Contact Us',
            icon: Icons.mail_rounded,
            onTap: () => _navigateTo(context, -5),
          ),

          const Divider(indent: 20, endIndent: 20),

          _sidebarItem(
            context,
            index: -6,
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
    Navigator.pop(context);
    if (index >= 0) {
      onTabChanged(index);
    } else if (index == -1) {
      // Notifications
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications feature coming soon')),
      );
    } else if (index == -2) {
      // Reviews & Ratings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviews & Ratings coming soon')),
      );
    } else if (index == -3) {
      // Settings
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings coming soon')));
    } else if (index == -4) {
      // Help & Support
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Help & Support coming soon')),
      );
    } else if (index == -5) {
      // Contact Us
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact us at support@tutorapp.com')),
      );
    }
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final auth = GetIt.instance<AuthService>();
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
