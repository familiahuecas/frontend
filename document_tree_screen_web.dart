import 'dart:html' as html; // Exclusivo para web
import 'dart:typed_data';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

import 'lib/apirest/api_service.dart';
import 'lib/model/exportable.dart';


class DocumentTreeScreenWeb extends StatefulWidget {
  const DocumentTreeScreenWeb({super.key});

  @override
  _DocumentTreeScreenWebState createState() => _DocumentTreeScreenWebState();
}

class _DocumentTreeScreenWebState extends State<DocumentTreeScreenWeb> {
  late Future<TreeNode<Explorable>> _treeFuture;
  final ApiService _apiService = ApiService();
  TreeNode<Explorable>? _selectedNode;

  @override
  void initState() {
    super.initState();
    _treeFuture = _loadDocumentTree();
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
          mimeType: json['mimeType'] ?? 'application/octet-stream',
          path: json['path'],
        ),
      );
    }
  }

  Future<void> _uploadFile(TreeNode<Explorable> node) async {
    if (node.data is Folder) {
      try {
        final uploadInput = html.FileUploadInputElement()..accept = '*/*';
        uploadInput.click();

        uploadInput.onChange.listen((event) async {
          final files = uploadInput.files;
          if (files != null && files.isNotEmpty) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(files[0]);

            reader.onLoadEnd.listen((_) async {
              final bytes = reader.result as Uint8List;
              final fileName = files[0].name;
              final parentId = (node.data as Folder).id;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subiendo archivo...')),
              );

              await _apiService.uploadFileWeb(bytes, fileName, parentId);

              setState(() {
                node.add(TreeNode<Explorable>(
                  data: File(
                    DateTime.now().millisecondsSinceEpoch,
                    fileName,
                    mimeType: 'application/octet-stream',
                    path: '',
                  ),
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Archivo subido con éxito.')),
                );
              });
            });
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el archivo: $e')),
        );
      }
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
            color: Colors.orangeAccent,
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
              showRootNode: false,
              expansionBehavior: ExpansionBehavior.scrollToLastChild,
              expansionIndicatorBuilder: (context, node) {
                return ChevronIndicator.rightDown(
                  tree: node,
                  alignment: Alignment.centerLeft,
                  color: Colors.grey[700],
                );
              },
              builder: (context, node) {
                final explorable = node.data!;
                final isSelected = node == _selectedNode; // Verifica si este nodo está seleccionado
                return ListTile(
                  tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null, // Fondo resaltado
                  leading: Icon(
                    explorable is Folder
                        ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                        : Icons.insert_drive_file,
                    color: isSelected
                        ? Colors.blueAccent // Ícono resaltado
                        : explorable is Folder
                        ? Colors.orangeAccent
                        : Colors.lightBlueAccent,
                  ),
                  title: Text(
                    explorable.name,
                    style: TextStyle(
                      color: isSelected ? Colors.blueAccent : null, // Texto resaltado
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: explorable is File ? Text(explorable.mimeType) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (explorable is Folder)
                        IconButton(
                          icon: const Icon(Icons.upload_file, color: Colors.green),
                          tooltip: 'Subir archivo',
                          onPressed: () => _uploadFile(node),
                        ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        tooltip: explorable is Folder ? 'Eliminar carpeta' : 'Eliminar archivo',
                        onPressed: () => _deleteDocument(node),
                      ),
                    ],
                  ),



                  onTap: () async {
                    _onNodeSelected(node);

                    // Verifica si es un archivo
                    if (explorable is File) {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Descargando archivo: ${explorable.name}')),
                        );

                        // Llama al servicio de descarga
                       // await _apiService.downloadFileWeb(explorable.id, explorable.name);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Archivo descargado: ${explorable.name}')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al descargar el archivo: $e')),
                        );
                      }
                    }
                  },

                );
              },
            ),
          );

        },
      ),
    );
  }
  Future<void> _deleteDocument(TreeNode<Explorable> node) async {
    if (node.data is Folder && (node.data as Folder).name == "Documentos") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar la carpeta raíz Documentos.')),
      );
      return;
    }

    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar este documento y su contenido?'),
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

      final documentId = node.data!.id; // ID del nodo
      print('Eliminando documento con ID: $documentId');

      // Llama al servicio para eliminar el documento
      await _apiService.deleteDocument(documentId);

      // Elimina el nodo del árbol localmente
      final parentNode = node.parent as TreeNode<Explorable>?;
      parentNode?.remove(node);

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento eliminado correctamente')),
        );
      });
    } catch (e) {
      print('Error al eliminar el documento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el documento: $e')),
      );
    }
  }

  void _onNodeSelected(TreeNode<Explorable> node) {
    setState(() {
      _selectedNode = node;
    });
  }
  TreeNode<Explorable>? _getSelectedNode() {
    return _selectedNode;
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
