import 'dart:io';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../apirest/api_service.dart';
import '../model/exportable.dart';
import 'package:path_provider/path_provider.dart';

class DocumentTreeScreen extends StatefulWidget {
  const DocumentTreeScreen({super.key});

  @override
  _DocumentTreeScreenState createState() => _DocumentTreeScreenState();
}

class _DocumentTreeScreenState extends State<DocumentTreeScreen> {
  late Future<TreeNode<Explorable>> _treeFuture;
  final ApiService _apiService = ApiService();
  TreeNode<Explorable>? _selectedNode;

  @override
  void initState() {
    super.initState();
    _treeFuture = _loadDocumentTree();
  }

  void _onNodeSelected(TreeNode<Explorable> node) {
    setState(() {
      _selectedNode = node;
    });
  }

  TreeNode<Explorable>? _getSelectedNode() {
    return _selectedNode;
  }

  Future<TreeNode<Explorable>> _loadDocumentTree() async {
    final json = await _apiService.getDocumentTree();
    return _buildTreeFromJson(json);
  }

  TreeNode<Explorable> _buildTreeFromJson(List<Map<String, dynamic>> json) {
    final rootNode = TreeNode<Explorable>.root(data: Folder(-1, "/root"));
    for (var item in json) {
      rootNode.add(_buildNode(item));
    }
    return rootNode;
  }

  TreeNode<Explorable> _buildNode(Map<String, dynamic> json) {
    if (json['esCarpeta'] == true) {
      final folderNode = TreeNode<Explorable>(
        data: Folder(json['id'], json['nombre']),
      );
      if (json['children'] != null) {
        for (var child in json['children']) {
          folderNode.add(_buildNode(child));
        }
      }
      return folderNode;
    } else {
      return TreeNode<Explorable>(
        data: File(
          json['id'],
          json['nombre'],
          mimeType: _getMimeTypeFromPath(json['path']),
          path: json['path'],
        ),
      );
    }
  }

  String _getMimeTypeFromPath(String? path) {
    if (path == null) return 'application/octet-stream';
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image/$extension';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'mp4':
        return 'video/mp4';
      case 'exe':
        return 'application/win32_exe';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            tooltip: 'Crear nueva carpeta',
            onPressed: _createNewFolder,
          ),
        ],
      ),
      body: FutureBuilder<TreeNode<Explorable>>(
        future: _treeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos disponibles.'));
          }

          final tree = snapshot.data!;
          return SafeArea(
            child: TreeView.simpleTyped<Explorable, TreeNode<Explorable>>(
              tree: tree,
              showRootNode: true,
              expansionBehavior: ExpansionBehavior.scrollToLastChild,
              expansionIndicatorBuilder: (context, node) {
                if (node.isRoot) {
                  return PlusMinusIndicator(
                    tree: node,
                    alignment: Alignment.centerLeft,
                    color: Colors.grey[700],
                  );
                }
                return ChevronIndicator.rightDown(
                  tree: node,
                  alignment: Alignment.centerLeft,
                  color: Colors.grey[700],
                );
              },
              builder: (context, node) {
                final explorable = node.data!;
                return ListTile(
                  leading: Icon(
                    explorable is Folder
                        ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                        : Icons.insert_drive_file,
                    color: explorable is Folder
                        ? Colors.orangeAccent
                        : Colors.lightBlueAccent,
                  ),
                  title: Text(explorable.name),
                  subtitle: explorable is File ? Text(explorable.mimeType) : null,
                  trailing: explorable is Folder
                      ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar carpeta',
                    onPressed: () => _deleteFolder(node),
                  )
                      : null,
                  onTap: () {
                    _onNodeSelected(node);
                    _deleteFolder(node);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _createNewFolder() async {
    final currentNode = _getSelectedNode();

    String? folderName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempName = '';
        return AlertDialog(
          title: const Text('Crear nueva carpeta'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Nombre de la carpeta'),
            onChanged: (value) {
              tempName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Crear'),
              onPressed: () {
                Navigator.of(context).pop(tempName);
              },
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.trim().isNotEmpty) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creando carpeta...')),
        );

        // Llama al servicio para persistir la carpeta
        int? parentId = currentNode?.data is Folder ? currentNode!.data?.id : null;
        final newFolderId = await _apiService.createFolder(parentId!, folderName);

        // Agrega la nueva carpeta al árbol en memoria
        final newFolder = Folder(newFolderId, folderName);

        if (currentNode != null && currentNode.data is Folder) {
          currentNode.add(TreeNode<Explorable>(data: newFolder));
        }

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carpeta creada correctamente.')),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la carpeta: $e')),
        );
      }
    }
  }
  void _deleteFolder(TreeNode<Explorable> node) async {
    if (node.data is Folder) {
      // Accede al nodo padre
      final parentNode = node.parent as TreeNode<Explorable>?;

      if (parentNode == null || parentNode.data is! Folder) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede eliminar el nodo raíz.')),
        );
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta carpeta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      try {
        final parentId = (parentNode.data as Folder).id;
        final childId = (node.data as Folder).id;

        if (parentId == null || childId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: IDs no válidos.')),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eliminando carpeta...')),
        );

        // Llama al servicio para eliminar la carpeta
        await _apiService.deleteFolder(parentId, childId);

        // Elimina el nodo del árbol localmente
        parentNode.remove(node);

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carpeta eliminada con éxito.')),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la carpeta: $e')),
        );
      }
    }
  }


}
