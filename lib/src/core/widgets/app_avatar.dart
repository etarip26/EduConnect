import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test_app/src/core/services/profile_image_service.dart';

class AppAvatar extends StatefulWidget {
  final String? name;
  final double radius;
  final VoidCallback? onTap;

  const AppAvatar({super.key, this.name, this.radius = 20, this.onTap});

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  File? _file;
  late final ValueNotifier<File?> _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ProfileImageService.instance.imageNotifier;
    _notifier.addListener(_onImageChanged);
    // initialize current value
    ProfileImageService.instance.getImage().then((f) {
      if (mounted) setState(() => _file = f);
    });
  }

  void _onImageChanged() {
    if (!mounted) return;
    setState(() {
      _file = _notifier.value;
    });
  }

  @override
  void dispose() {
    _notifier.removeListener(_onImageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = (widget.name ?? '').isNotEmpty
        ? widget.name!
              .trim()
              .split(' ')
              .map((s) => s.isNotEmpty ? s[0] : '')
              .take(2)
              .join()
        : null;

    final Widget content;
    if (_file != null) {
      content = Image.file(
        _file!,
        width: widget.radius * 2,
        height: widget.radius * 2,
        fit: BoxFit.cover,
        key: ValueKey('file:${_file!.path}'),
      );
    } else if (initials != null && initials.isNotEmpty) {
      content = Text(
        initials.toUpperCase(),
        key: ValueKey('initials:$initials'),
        style: TextStyle(fontSize: widget.radius * 0.7, color: Colors.indigo),
      );
    } else {
      content = Icon(
        Icons.person,
        key: const ValueKey('icon'),
        size: widget.radius,
        color: Colors.indigo,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: content,
          ),
        ),
      ),
    );
  }
}
