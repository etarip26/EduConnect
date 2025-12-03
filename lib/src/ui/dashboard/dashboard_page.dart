import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Tabs
import 'tab/home_tab.dart';
import 'tab/chat_tab.dart';
import 'tab/tuition_tab.dart';
import 'tab/profile_tab.dart';
import 'tab/search_tab.dart';
import 'tab/admin_tab.dart'; // NEW
import 'app_sidebar.dart'; // NEW SIDEBAR

import 'package:test_app/src/core/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  int index = 0;

  late final AuthService auth = GetIt.instance<AuthService>();

  late final bool isAdmin = (auth.role == "admin");

  late final List<Widget> pages = [
    const HomeTab(),
    const SearchTab(),
    const ChatTab(),
    const TuitionTab(),
    isAdmin ? const AdminTab() : const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: AppSidebar(
        currentIndex: index,
        onTabChanged: (newIndex) {
          setState(() => index = newIndex);
        },
      ),
      extendBody: true,

      //==========================================================
      //                      BODY (FADE SWITCH)
      //==========================================================
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        child: pages[index],
      ),

      //==========================================================
      //                   PREMIUM GLASS NAVBAR
      //==========================================================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        height: 72,
        decoration: BoxDecoration(
          color: (isDark
              ? Colors.white12
              : Colors.white.withAlpha((0.4 * 255).round())),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha((0.4 * 255).round())
                  : Colors.blueGrey.withAlpha((0.12 * 255).round()),
              blurRadius: 25,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(Icons.home_rounded, 0),
                navItem(Icons.search_rounded, 1),
                navItem(Icons.chat_bubble_rounded, 2),
                navItem(Icons.book_rounded, 3),

                // LAST TAB CHANGES BASED ON ROLE
                navItem(
                  isAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.person_rounded,
                  4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //==========================================================
  //                     NAV ITEM WIDGET
  //==========================================================
  Widget navItem(IconData icon, int i) {
    final selected = (i == index);

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(10),
        curve: Curves.easeOutQuint,
        decoration: BoxDecoration(
          color: selected
              ? Colors.indigo.withAlpha((0.12 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: selected ? 30 : 26,
          color: selected ? Colors.indigo : Colors.grey.shade500,
        ),
      ),
    );
  }
}
