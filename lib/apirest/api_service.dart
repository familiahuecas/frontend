import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/numeracion.dart';
import '../model/recaudaciones.dart';
import '../model/recaudacionrequest.dart';
import '../model/recaudacionresponse.dart';
import '../model/user.dart';

class ApiService {
  final String baseUrl = kIsWeb
      ? '${const String.fromEnvironment('API_URL_WEB')}/backend'  // URL para la web
      : '${const String.fromEnvironment('API_URL')}/backend'; // URL para el teléfono

  // Método para obtener el token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método para guardar el token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Método para guardar el usuario
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson())); // Guardar usuario como JSON
  }

  // Método para obtener el usuario
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson)); // Convertir JSON a objeto User
    }
    return null;
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

      // Si la respuesta es exitosa, decodifica y retorna
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Si no es exitosa, lanza un error con el mensaje del servidor
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }


  // Método GET para obtener usuarios
  Future<List<User>> getUsers() async {
    print('Haciendo llamada a: getUsers');
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

  // Método para obtener numeraciones paginadas
  Future<NumeracionPage> getNumeraciones(int page, int size) async {
    final url = Uri.parse('$baseUrl/numeracion/list?page=$page&size=$size');
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
        // Mapea la respuesta JSON al modelo NumeracionPage
        return NumeracionPage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para eliminar numeraciones con autenticación
  Future<void> deleteNumeracion(int id) async {
    final url = Uri.parse('$baseUrl/numeracion/deleteNumeracion/$id');
    final token = await _getToken(); // Obtener el token almacenado

    print('Haciendo llamada DELETE a: $url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta recibida: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la numeración: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para calcular la recaudación
  Future<Recaudacionresponse> calculateRec(Recaudacionrequest request) async {
    final url = Uri.parse('$baseUrl/numeracion/calculateRec');
    final token = await _getToken();

    // Log para ver qué se le envía al servicio
    print('Enviando solicitud a: $url');
    print('Headers: ${{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    }}');
    print('Body: ${request.toJson()}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()), // Convertir el objeto request a JSON
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) {
        return Recaudacionresponse.fromJson(jsonDecode(response.body)); // Mapear la respuesta a RecaudacionResponse
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para guardar la recaudación
  Future<void> guardarRecaudacion(Recaudacionrequest request) async {
    final url = Uri.parse('$baseUrl/numeracion/guardar');
    final token = await _getToken();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        print('Recaudación guardada con éxito');
      } else {
        throw Exception('Error al guardar la recaudación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  Future<RecaudacionesPage> getRecaudaciones(int page, int size) async {
    final url = Uri.parse('$baseUrl/numeracion/listrecaudacion?page=$page&size=$size');
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
        // Mapea la respuesta JSON al modelo RecaudacionesPage
        return RecaudacionesPage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para obtener usuarios paginados
  Future<UserPage> getUsersPaginated(int page, int size) async {
    final url = Uri.parse('$baseUrl/users/listpaginated?page=$page&size=$size');
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
        // Mapea la respuesta JSON al modelo UserPage
        return UserPage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para eliminar usuarios
  Future<void> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/users/delete/$id');
    final token = await _getToken();
    print('Haciendo llamada DELETE a: $url');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Respuesta recibida: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  Future<void> createUser(User user) async {
    print('Preparando para guardar usuario: ${user.toJson()}');
    final url = Uri.parse('$baseUrl/users/create');
    final token = await _getToken(); // Obtener el token almacenado

    print('Haciendo llamada a: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()), // Convertir el objeto User a JSON
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) { // Suponiendo que el backend responde con 200 para creación exitosa
        print('Usuario guardado exitosamente');
      } else {
        throw Exception('Error al guardar el usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al guardar el usuario: $e');
      throw Exception('Error de red o del servidor: $e');
    }
  }


}
