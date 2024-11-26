import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/conceptogastoadelanto.dart';
import '../model/documentnode.dart';
import '../model/numeracion.dart';
import '../model/recaudaciones.dart';
import '../model/recaudacionrequest.dart';
import '../model/recaudacionresponse.dart';
import '../model/user.dart';
import '../model/usuarioconadelanto.dart';
import '../model/usuarioconapuntes.dart';
import 'package:mime/mime.dart';

//import 'download_file_service.dart';
//import 'dart:html' as html; // Para la web


class ApiService {
  final String baseUrl = kIsWeb
      ? '${const String.fromEnvironment('API_URL_WEB')}/backend'  // URL para la web
      : '${const String.fromEnvironment('API_URL')}/backend'; // URL para el teléfono
  //final DownloadFileService _downloadFileService = DownloadFileService();
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
  Future<List<UsuarioConApuntes>> getUsuariosConApuntes() async {
    final url = Uri.parse('$baseUrl/adelanto/usuariosconapuntes');
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((data) => UsuarioConApuntes.fromJson(data)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener usuarios con apuntes: $e');
    }
  }
  Future<List<ConceptoGastoAdelanto>> getConceptosGastoPaginated(int page, int size) async {
    final url = Uri.parse('$baseUrl/conceptos/list?page=$page&size=$size');
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];

        return content.map((data) => ConceptoGastoAdelanto.fromJson(data)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener conceptos de gasto: $e');
    }
  }
  Future<List<ConceptoGastoAdelanto>> getConceptosGastoByUsuario(String usuario, int page, int size) async {
    final url = Uri.parse(
        '$baseUrl/conceptos/list?usuario=$usuario&page=$page&size=$size');
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
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content']; // Accede a la clave 'content'

        // Mapea los elementos de 'content' a una lista de objetos
        return content.map((data) => ConceptoGastoAdelanto.fromJson(data)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener conceptos de gasto: $e');
    }
  }
  Future<void> crearApunte(ConceptoGastoAdelanto apunte) async {
    print('Preparando para guardar apunte: ${apunte.toJson()}');
    final url = Uri.parse('$baseUrl/conceptos/create');
    final token = await _getToken(); // Obtener el token almacenado

    print('Haciendo llamada a: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(apunte.toJson()), // Convertir el objeto Apunte a JSON
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) { // Suponiendo que el backend responde con 200 para creación exitosa
        print('Apunte guardado exitosamente');
      } else {
        throw Exception('Error al guardar el apunte: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al guardar el apunte: $e');
      throw Exception('Error de red o del servidor: $e');
    }
  }
  // Método para eliminar usuarios
  Future<void> deleteApunte(int id) async {
    final url = Uri.parse('$baseUrl/conceptos/delete/$id');
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
  Future<void> crearAdelanto(UsuarioConAdelanto adelanto) async {
    print('Preparando para guardar adelanto: ${adelanto.toJson()}');
    final url = Uri.parse('$baseUrl/adelanto/create');
    final token = await _getToken(); // Obtener el token almacenado

    print('Haciendo llamada a: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(adelanto.toJson()), // Convertir el objeto Adelanto a JSON
      );

      print('Respuesta recibida: ${response.body}');

      if (response.statusCode == 200) {
        print('Adelanto guardado exitosamente');
      } else {
        throw Exception('Error al guardar el adelanto: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al guardar el adelanto: $e');
      throw Exception('Error de red o del servidor: $e');
    }
  }
  Future<void> deleteAdelanto(int id) async {
    final url = Uri.parse('$baseUrl/adelanto/delete/$id');
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
        throw Exception('Error al eliminar el adelanto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
// Método para obtener el árbol de documentos
  Future<List<Map<String, dynamic>>> getDocumentTree() async {
    final url = Uri.parse('$baseUrl/documentos/tree');
    final token = await _getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Error al obtener el árbol de documentos: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
// Método para subir un archivo
  Future<void> uploadFile(String filePath, int parentId) async {
    final url = Uri.parse('$baseUrl/documentos/upload?parentId=$parentId');
    final token = await _getToken();

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Error al subir el archivo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de red o del servidor: $e');
    }
  }
  Future<void> downloadFile(int id, String fileName) async {
    final url = '$baseUrl/documentos/download/$id';
    final token = await _getToken(); // Obtén el token JWT de tu lógica

    try {
      // Descarga el archivo como bytes
      final response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $token', // Agrega el token a los headers
          },
        ),
      );

      if (response.statusCode == 200) {
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

        // Guarda el archivo con FileSaver
        await FileSaver.instance.saveFile(
          fileName,
          Uint8List.fromList(response.data),
          mimeType.split('/').last, // Extensión del archivo
        );
      } else {
        throw Exception('Error al descargar el archivo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al descargar el archivo: $e');
    }
  }



  Future<List<Map<String, dynamic>>> getDocumentTreeNode() async {
    final url = Uri.parse('$baseUrl/documentos/tree');
    print('Haciendo llamada a: $url');
    try {
      final response = await http.get(url);
      print('Respuesta recibida: ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Error al obtener el árbol de documentos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectarse al servicio: $e');
    }
  }
  Future<int> createFolder(int parentId, String folderName) async {
    final url = '$baseUrl/documentos/add-node?parentId=$parentId';
    final token = await _getToken();
    final folderData = {
      "nombre": folderName,
      "esCarpeta": true,
      "path": null,
    };

    try {
      print('Enviando solicitud a: $url');
      print('Datos enviados: $folderData');

      final response = await Dio().post(
        url,
        data: folderData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Asegúrate de que el backend devuelve un objeto con el `id`
        final newFolderId = response.data['id']; // Ajusta según la estructura real del JSON de respuesta
        print('Carpeta creada con éxito: ID $newFolderId');
        return newFolderId;
      } else {
        throw Exception(
          'Error al crear la carpeta: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('Error al enviar la solicitud: $e');
      rethrow;
    }
  }

  Future<void> deleteFolder(int parentId, int childId) async {
    final url = '$baseUrl/documentos/$parentId/remove-child/$childId';
    final token = await _getToken();

    try {
      final response = await Dio().delete(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la carpeta: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error al eliminar la carpeta: $e');
      rethrow;
    }
  }

}
