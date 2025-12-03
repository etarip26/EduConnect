import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumNavBar extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const PremiumNavBar({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.75 * 255).round()),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.06 * 255).round()),
                offset: const Offset(0, -2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(icon: Icons.home_rounded, label: "Home", i: 0),
              _item(icon: Icons.chat_rounded, label: "Chat", i: 1),
              _item(icon: Icons.book_rounded, label: "Tuition", i: 2),
              _item(icon: Icons.search_rounded, label: "Search", i: 3),
              _item(icon: Icons.person_rounded, label: "Profile", i: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required int i,
  }) {
    final isActive = index == i;

    return GestureDetector(
      onTap: () => onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.indigo.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isActive ? 30 : 26,
              color: isActive ? Colors.indigo : Colors.grey.shade600,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isActive ? 14 : 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.indigo : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
