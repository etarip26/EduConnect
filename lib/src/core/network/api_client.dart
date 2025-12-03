import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test_app/src/config/env.dart';
import 'package:test_app/src/core/services/storage_service.dart';

class ApiClient {
  final String baseUrl;
  final StorageService storage;

  ApiClient({required this.storage, this.baseUrl = Env.apiBase});

  // -------------------------------------------------------------
  // HEADERS
  // -------------------------------------------------------------
  Future<Map<String, String>> _headers() async {
    final token = await storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // -------------------------------------------------------------
  // GET
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query ?? {});
    final resp = await http.get(uri, headers: await _headers());
    return _decode(resp);
  }

  // -------------------------------------------------------------
  // POST (Body is optional)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.post(
      uri,
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _decode(resp);
  }

  // -------------------------------------------------------------
  // PUT
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(resp);
  }

  // -------------------------------------------------------------
  // PATCH
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.patch(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(resp);
  }

  // -------------------------------------------------------------
  // DELETE
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.delete(uri, headers: await _headers());
    return _decode(resp);
  }

  // -------------------------------------------------------------
  // SAFE DECODER
  // -------------------------------------------------------------
  Map<String, dynamic> _decode(http.Response resp) {
    try {
      if (resp.body.isEmpty) {
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          return {};
        }
        throw ApiException(
          statusCode: resp.statusCode,
          message: 'HTTP ${resp.statusCode} Error',
        );
      }

      final decoded = jsonDecode(resp.body);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      }

      throw ApiException(
        statusCode: resp.statusCode,
        message: decoded is Map && decoded['message'] is String
            ? decoded['message']
            : 'HTTP ${resp.statusCode} Error',
      );
    } catch (e) {
      throw ApiException(
        statusCode: resp.statusCode,
        message: 'Invalid server response',
      );
    }
  }
}

// -------------------------------------------------------------
// ERROR CLASS
// -------------------------------------------------------------
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
