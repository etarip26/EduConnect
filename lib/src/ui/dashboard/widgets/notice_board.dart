import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/src/core/services/announcement_service.dart';

class NoticeBoard extends StatefulWidget {
  const NoticeBoard({super.key});

  @override
  State<NoticeBoard> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  final announcementService = GetIt.instance<AnnouncementService>();
  List<Map<String, dynamic>> announcements = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      setState(() => loading = true);
      final data = await announcementService.getActiveAnnouncements();
      setState(() {
        announcements = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load announcements";
        loading = false;
      });
      print("NoticeBoard error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _loadingPlaceholder();
    }

    if (error != null) {
      return _errorPlaceholder(error!);
    }

    if (announcements.isEmpty) {
      return _emptyPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📢 Notice Board",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: announcements
                .map((announcement) => _announcementCard(announcement))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _announcementCard(Map<String, dynamic> announcement) {
    final type = announcement['type'] ?? 'info';
    final title = announcement['title'] ?? 'Announcement';
    final description = announcement['description'] ?? '';

    Color bgColor;
    Color borderColor;
    IconData iconData;

    switch (type) {
      case 'alert':
        bgColor = const Color(0xFFFFEBEE);
        borderColor = Colors.red;
        iconData = Icons.warning;
        break;
      case 'success':
        bgColor = const Color(0xFFE8F5E9);
        borderColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'info':
      default:
        bgColor = const Color(0xFFE3F2FD);
        borderColor = Colors.blue;
        iconData = Icons.info;
        break;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(iconData, color: borderColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF0F0F0),
      ),
      child: const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorPlaceholder(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFFEBEE),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF5F5F5),
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No announcements at the moment",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
