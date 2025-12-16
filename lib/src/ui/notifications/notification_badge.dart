import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/notification_service.dart';
import 'package:test_app/src/ui/notifications/notifications_page.dart';

class NotificationBadge extends StatefulWidget {
  final double size;
  final bool autoRefresh;

  const NotificationBadge({Key? key, this.size = 32, this.autoRefresh = true})
    : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  late NotificationService _notificationService;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = GetIt.instance.get<NotificationService>();
    _loadUnreadCount();

    if (widget.autoRefresh) {
      // Refresh unread count every 30 seconds
      Future.delayed(const Duration(seconds: 30)).then((_) {
        if (mounted) _loadUnreadCount();
      });
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final result = await _notificationService.getMyNotifications(
        page: 1,
        limit: 1,
      );
      if (mounted) {
        setState(() {
          _unreadCount = result['unreadCount'] ?? 0;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          iconSize: widget.size - 4,
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                )
                .then((_) => _loadUnreadCount());
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
