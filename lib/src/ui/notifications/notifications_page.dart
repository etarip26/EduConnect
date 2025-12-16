import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/notification_service.dart';
import 'package:test_app/src/ui/components/app_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationService _notificationService;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = GetIt.instance.get<NotificationService>();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final result = await _notificationService.getMyNotifications(page: 1, limit: 50);
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(result['notifications'] ?? []);
        _unreadCount = result['unreadCount'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String notificationId, int index) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      setState(() {
        _notifications[index]['isRead'] = true;
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId, int index) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      setState(() {
        if (_notifications[index]['isRead'] == false) {
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        }
        _notifications.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'Notifications',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['isRead'] ?? false;
                    final createdAt = notification['createdAt'];
                    final timeAgo = createdAt != null
                        ? timeago.format(DateTime.parse(createdAt))
                        : 'Just now';

                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : Colors.indigo[50],
                        border: Border.all(
                          color: isRead ? Colors.grey[200]! : Colors.indigo[200]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.indigo[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconForType(notification['type']),
                            color: Colors.indigo[600],
                          ),
                        ),
                        title: Text(
                          notification['title'] ?? 'Notification',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification['message'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeAgo,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            if (!isRead)
                              PopupMenuItem(
                                child: const Text('Mark as read'),
                                onTap: () => _markAsRead(notification['_id'], index),
                              ),
                            PopupMenuItem(
                              child: const Text('Delete'),
                              onTap: () => _deleteNotification(notification['_id'], index),
                            ),
                          ],
                        ),
                        onTap: !isRead ? () => _markAsRead(notification['_id'], index) : null,
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'application_approved':
        return Icons.check_circle;
      case 'application_rejected':
        return Icons.cancel;
      case 'tuition_approved':
        return Icons.verified;
      case 'message':
        return Icons.mail;
      default:
        return Icons.notifications;
    }
  }
}
