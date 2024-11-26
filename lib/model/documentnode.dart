import 'package:animated_tree_view/tree_view/tree_node.dart';

class DocumentNode extends TreeNode<DocumentNode> {
  final int id;
  final String nombre;
  final bool esCarpeta;
  final String? _path;
  final Map<String, DocumentNode> _children;

  DocumentNode({
    required this.id,
    required this.nombre,
    required this.esCarpeta,
    String? path,
    Map<String, DocumentNode>? children,
  })  : _path = path,
        _children = children ?? {};

  // Implementación del getter `path` requerido por `INode`
  @override
  String get path => _path ?? '';

  // Implementación del getter `children` requerido por `Node`
  @override
  Map<String, DocumentNode> get children => _children;

  // Constructor de fábrica para crear un nodo a partir de JSON
  factory DocumentNode.fromJson(Map<String, dynamic> json) {
    final childrenList = (json['children'] as List<dynamic>)
        .map((child) => DocumentNode.fromJson(child))
        .toList();
    return DocumentNode(
      id: json['id'],
      nombre: json['nombre'],
      esCarpeta: json['esCarpeta'],
      path: json['path'],
      children: {for (var child in childrenList) child.nombre: child},
    );
  }

  // Método para convertir un nodo en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'esCarpeta': esCarpeta,
      'path': _path,
      'children': _children.values.map((child) => child.toJson()).toList(),
    };
  }

  // Método para agregar un hijo al nodo actual
  void addChild(DocumentNode child) {
    _children[child.nombre] = child;
  }

  // Método para eliminar un hijo del nodo actual
  void removeChild(String childName) {
    _children.remove(childName);
  }
}
