import 'package:familiahuecasfrontend/apirest/api_service.dart'; // Importa tu ApiService

class ApiHelper {
  final ApiService _apiService = ApiService(); // Crea una instancia de ApiService

  /// Método para llamar al API de Numeraciones
  Future<dynamic> getNumeraciones(int page, int size) async {
    try {
      // Llama al método correspondiente en ApiService
      final response = await _apiService.getNumeraciones(page, size);
      return response;
    } catch (error) {
      print('Error al llamar a getNumeraciones: $error');
      throw error; // Vuelve a lanzar el error para que sea manejado en otro lugar si es necesario
    }
  }

// Aquí puedes agregar otros métodos para diferentes llamadas a la API
// Ejemplo:
// Future<dynamic> getAnotherEndpoint(int param) async {
//   try {
//     final response = await _apiService.getAnotherEndpoint(param);
//     return response;
//   } catch (error) {
//     print('Error al llamar a getAnotherEndpoint: $error');
//     throw error;
//   }
// }
}
