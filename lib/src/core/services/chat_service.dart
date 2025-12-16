import 'dart:async';
import 'package:test_app/src/core/network/api_client.dart';
import 'package:test_app/src/config/api_paths.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get_it/get_it.dart';
import 'auth_service.dart';

class ChatService {
  final ApiClient api;
  IO.Socket? _socket;
  late AuthService _authService;

  // Callbacks for real-time updates
  Function(Map<String, dynamic> message)? onNewMessage;
  Function(String userId)? onTyping;
  Function(String userId)? onTypingStop;
  Function(String roomId)? onMessagesRead;
  Function(Map<String, dynamic> adminMessage)? onAdminMessage;
  Function(String messageId)? onAdminMessageRead;

  ChatService({required this.api}) {
    _authService = GetIt.I<AuthService>();
  }

  // ===============================================
  // SOCKET CONNECTION
  // ===============================================

  /// Initialize and connect to Socket.io server
  Future<void> connectSocket() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _authService.getToken();
    if (token == null) return;

    _socket = IO.io(
      'http://localhost:5000', // Or your backend URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _setupSocketListeners();
    _socket!.connect();
  }

  /// Setup all socket event listeners
  void _setupSocketListeners() {
    _socket?.on('connect', (_) {
      print('✅ Socket connected');
    });

    _socket?.on('joinedRoom', (data) {
      print('Joined room: ${data['roomId']}');
    });

    _socket?.on('joinedAdminChannel', (data) {
      print('Joined admin channel: ${data['channelId']}');
    });

    _socket?.on('joinedUserNotifications', (data) {
      print('Joined notifications: ${data['channelId']}');
    });

    // New message received in chat
    _socket?.on('newMessage', (data) {
      onNewMessage?.call(data);
      print('New message: ${data['text']}');
    });

    // Admin message received
    _socket?.on('newAdminMessage', (data) {
      onAdminMessage?.call(data);
      print('Admin message: ${data['message']}');
    });

    // Typing indicators
    _socket?.on('typing', (data) {
      if (data['isTyping'] == true) {
        onTyping?.call(data['userId']);
      } else {
        onTypingStop?.call(data['userId']);
      }
    });

    // Messages marked as read
    _socket?.on('messagesRead', (data) {
      onMessagesRead?.call(data['roomId']);
    });

    _socket?.on('adminMessageRead', (data) {
      onAdminMessageRead?.call(data['messageId']);
    });

    // Errors
    _socket?.on('error', (data) {
      print('Socket error: ${data['message']}');
    });

    _socket?.on('disconnect', (_) {
      print('Socket disconnected');
    });
  }

  /// Disconnect socket
  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }

  // ===============================================
  // MATCH-BASED CHAT (Student-Teacher)
  // ===============================================

  Future<List<dynamic>> getMyRooms() async {
    final res = await api.get(ApiPaths.myChatRooms);
    return res["rooms"] ?? [];
  }

  Future<List<dynamic>> getMessages(String roomId) async {
    final res = await api.get(ApiPaths.chatMessages(roomId));
    return res["messages"] ?? res["data"] ?? [];
  }

  Future<Map<String, dynamic>> createOrGetRoom(String matchId) async {
    final res = await api.post(ApiPaths.chatRooms, {"matchId": matchId});
    return res["room"] ?? {};
  }

  /// Join a chat room via socket (for real-time updates)
  void joinRoom(String roomId) {
    if (_socket == null || !_socket!.connected) {
      unawaited(connectSocket());
    }
    _socket?.emit('joinRoom', {'roomId': roomId});
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    _socket?.off('newMessage');
    _socket?.off('typing');
    _socket?.off('messagesRead');
  }

  /// Send message via Socket.io (real-time)
  void sendMessageLive(String roomId, String text) {
    if (_socket == null || !_socket!.connected) {
      unawaited(connectSocket());
    }
    _socket?.emit('sendMessage', {'roomId': roomId, 'text': text});
  }

  /// Fallback: Send message via REST API
  Future<Map<String, dynamic>> sendMessage(String roomId, String text) async {
    final res = await api.post(ApiPaths.chatMessages(roomId), {"text": text});
    return res["data"] ?? {};
  }

  /// Send typing indicator
  void sendTyping(String roomId, {bool isTyping = true}) {
    if (_socket == null || !_socket!.connected) return;
    _socket?.emit('typing', {'roomId': roomId, 'isTyping': isTyping});
  }

  /// Mark messages as read
  void markMessagesRead(String roomId) {
    if (_socket == null || !_socket!.connected) return;
    _socket?.emit('markRead', {'roomId': roomId});
  }

  // ===============================================
  // ADMIN ONE-WAY MESSAGING
  // ===============================================

  /// Join user's notification channel to receive admin messages
  void joinUserNotifications() {
    if (_socket == null || !_socket!.connected) {
      unawaited(connectSocket());
    }
    _socket?.emit('joinUserNotifications');
  }

  /// Join admin channel (admin only) to send messages to a user
  void joinAdminChannel(String userId) {
    if (_socket == null || !_socket!.connected) {
      unawaited(connectSocket());
    }
    _socket?.emit('joinAdminChannel', {'userId': userId});
  }

  /// Admin sends real-time message to user (one-way)
  void sendAdminMessageLive({
    required String recipientId,
    required String message,
    String? title,
  }) {
    if (_socket == null || !_socket!.connected) {
      unawaited(connectSocket());
    }
    _socket?.emit('sendAdminMessage', {
      'recipientId': recipientId,
      'message': message,
      'title': title ?? 'Message from Admin',
    });
  }

  /// User marks admin message as read
  void markAdminMessageRead(String messageId) {
    if (_socket == null || !_socket!.connected) return;
    _socket?.emit('markAdminMessageRead', {'messageId': messageId});
  }

  /// Get admin messages via REST API
  Future<List<dynamic>> getAdminMessages() async {
    try {
      final res = await api.get('/api/notifications');
      return res['notifications'] ?? res['messages'] ?? [];
    } catch (e) {
      print('Error fetching admin messages: $e');
      return [];
    }
  }

  /// Is socket connected
  bool get isConnected => _socket?.connected ?? false;
}
