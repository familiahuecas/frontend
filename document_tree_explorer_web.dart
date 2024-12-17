import 'dart:html' as html; // Exclusivo para web
import 'dart:typed_data';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

import 'lib/apirest/api_service.dart';
import 'lib/model/exportable.dart';

class DocumentTreeExplorerWeb extends StatefulWidget {
  const DocumentTreeExplorerWeb({super.key});

  @override
  _DocumentTreeExplorerWebState createState() => _DocumentTreeExplorerWebState();
}

class _DocumentTreeExplorerWebState extends State<DocumentTreeExplorerWeb> {
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

  Future<void> _createNewFolder() async {
    final currentNode = _selectedNode;

    if (currentNode == null || currentNode.data is! Folder) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Por favor, selecciona una carpeta antes de crear una nueva.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

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

        final parentId = (currentNode.data as Folder).id;
        final newFolderId = await _apiService.createFolder(parentId, folderName);

        setState(() {
          currentNode.add(TreeNode<Explorable>(data: Folder(newFolderId, folderName)));
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

      final documentId = node.data!.id;
      await _apiService.deleteDocument(documentId);

      setState(() {
        final parentNode = node.parent as TreeNode<Explorable>?;
        parentNode?.remove(node);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documento eliminado correctamente')),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el documento: $e')),
      );
    }
  }

  Widget _buildFileViewer(TreeNode<Explorable>? node) {
    if (node == null || node.data is! File) {
      return const Center(child: Text('Selecciona un archivo para ver su contenido.'));
    }
    final file = node.data as File;

    if (file.mimeType.startsWith('image/')) {
      return Image.network(
        '${_apiService.baseUrl}/documentos/download/${file.id}',
        fit: BoxFit.contain,
      );
    } else if (file.mimeType == 'application/pdf') {
      return Center(
        child: TextButton(
          onPressed: () {
            html.window.open('${_apiService.baseUrl}/documentos/download/${file.id}', '_blank');
          },
          child: const Text('Abrir PDF en una nueva pestaña'),
        ),
      );
    }/* else if (file.mimeType.startsWith('text/')) {
      return FutureBuilder<String>(
        future: _apiService.getFileContentAsText(file.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar archivo: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(child: Text(snapshot.data!)),
            );
          }
        },
      );
    }*/ else {
      return Center(
        child: Text('No se puede previsualizar este archivo: ${file.mimeType}'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorador de Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
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
          return Row(
            children: [
              Expanded(
                flex: 1,
                child: TreeView.simpleTyped<Explorable, TreeNode<Explorable>>(
                  tree: tree,
                  showRootNode: false,
                  expansionBehavior: ExpansionBehavior.scrollToLastChild,
                  expansionIndicatorBuilder: (context, node) {
                    return ChevronIndicator.rightDown(
                      tree: node,
                      alignment: Alignment.centerLeft,
                    );
                  },
                  builder: (context, node) {
                    final isSelected = node == _selectedNode;
                    return ListTile(
                      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      leading: Icon(
                        node.data is Folder
                            ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                            : Icons.insert_drive_file,
                      ),
                      title: Text(node.data!.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (node.data is Folder)
                            IconButton(
                              icon: const Icon(Icons.upload_file, color: Colors.green),
                              tooltip: 'Subir archivo',
                              onPressed: () => _uploadFile(node),
                            ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            tooltip: node.data is Folder ? 'Eliminar carpeta' : 'Eliminar archivo',
                            onPressed: () => _deleteDocument(node),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedNode = node;
                        });
                      },
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildFileViewer(_selectedNode),
              ),
            ],
          );
        },
      ),
    );
  }
}
