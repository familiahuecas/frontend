abstract class Explorable {
  final String name;
  final int id; // Nuevo atributo para almacenar el ID
  final DateTime createdAt;

  Explorable(this.id, this.name) : createdAt = DateTime.now(); // Se incluye el ID en el constructor

  @override
  String toString() => name;
}

class File extends Explorable {
  final String mimeType;
  final String path;

  File(int id, String name, {required this.mimeType, required this.path}) : super(id, name);
}

class Folder extends Explorable {
  Folder(int id, String name) : super(id, name);
}
