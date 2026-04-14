import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  // ── GET ───────────────────────────────────────────────────────────────────
  Future<dynamic> get(String path) async {
    try {
      final res = await http
          .get(_uri(path), headers: _headers)
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('No internet connection. Check server at ${ApiConfig.baseUrl}');
    } on HttpException {
      throw ApiException('Server not reachable');
    }
  }

  // ── POST ──────────────────────────────────────────────────────────────────
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  // ── PUT ───────────────────────────────────────────────────────────────────
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(_uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<dynamic> delete(String path) async {
    try {
      final res = await http
          .delete(_uri(path), headers: _headers)
          .timeout(ApiConfig.receiveTimeout);
      return _handleResponse(res);
    } on SocketException {
      throw ApiException('No internet connection');
    }
  }

  // ── Response Handler ──────────────────────────────────────────────────────
  dynamic _handleResponse(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body is Map ? (body['message'] ?? 'Request failed') : 'Request failed';
    throw ApiException(msg.toString(), res.statusCode);
  }
}
