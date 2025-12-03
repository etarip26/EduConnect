import 'package:flutter/material.dart';

class AdminSidebar extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminSidebar({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A2332), const Color(0xFF0F1419)],
        ),
        border: Border(
          right: BorderSide(color: const Color(0xFF00D4FF).withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D4FF),
                        const Color(0xFF00B8E6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'EduConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: const Color(0xFF00D4FF).withOpacity(0.1), height: 1),
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.people,
                  label: 'Users',
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.school,
                  label: 'Students',
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.person_pin,
                  label: 'Teachers',
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                _buildMenuItem(
                  index: 4,
                  icon: Icons.book,
                  label: 'Tuitions',
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                _buildMenuItem(
                  index: 5,
                  icon: Icons.video_call,
                  label: 'Demo Sessions',
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                _buildMenuItem(
                  index: 6,
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
              ],
            ),
          ),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1744).withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.2),
                      const Color(0xFF00B8E6).withOpacity(0.1),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00D4FF).withOpacity(0.4)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF00D4FF)
                    : Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00D4FF) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
