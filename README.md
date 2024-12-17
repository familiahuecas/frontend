# familiahuecasfrontend

front en flutter de familia huecas

## Getting Started
desarrollado para flutter_3.24.5

para construir la apk del movil
flutter build apk --dart-define=API_URL=http://82.223.205.118
build/app/output/flutter-apk/app-release.apk

libreria file_saver customizada. poner en la ruta: C:\Users\vmhuecas\AppData\Local\Pub\Cache\hosted\pub.dev
me pide file_saver: ^0.0.7 al compilar en web, aunque creo que no la uso....

COMPILACION MOVIL O WEB. Hay dos ficheros. document_tree_screem. Cuando queramos compilar para web ponemos en la carpeta screen el fichero documento_tree_screen_web.dart y si es para movil el documento_tree_screen_movil.dart

En la vista del login, para web comentar el tema de permisos de movil, si no da error:
//import 'package:permission_handler/permission_handler.dart'; // Importar la librería de permisos
// Solicitar permisos antes de navegar a la pantalla principal
/*  final hasPermission = await _requestStoragePermission();
if (!hasPermission) {
throw Exception('Permisos de almacenamiento denegados.');
}
*/
/* Future<bool> _requestStoragePermission() async {
final status = await Permission.storage.request();
return status.isGranted;
}*/
y en documentos.dart cambiar a DocumentTreeScreenWeb o DocumentTreeScreenMovil segun compilacion (WEB o MOVIL) 