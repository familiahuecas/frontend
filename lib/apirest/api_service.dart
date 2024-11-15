import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class ApiService {
  final String baseUrl = kIsWeb
      ? '${const String.fromEnvironment('API_URL_WEB')}/backend'  // URL para la web
      : '${const String.fromEnvironment('API_URL')}/backend'  ;// URL para la phone

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final token = requiresAuth ? await _getToken() : null;
    print('Haciendo llamada a: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }


  Future<List<User>> getUsers() async {
    final url = Uri.parse('$baseUrl/users/list');
    final token = await _getToken();
    print('Haciendo llamada a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData.map((data) => User.fromJson(data)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
}
