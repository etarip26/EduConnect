import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PremiumCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withAlpha((0.05 * 255).round()),
              offset: const Offset(0, 3),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
