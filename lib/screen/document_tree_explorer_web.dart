import 'dart:html' as html; // Exclusivo para web
import 'dart:typed_data';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

import '../../../apirest/api_service.dart';
import '../../../model/exportable.dart';

class DocumentTreeExplorerWeb extends StatefulWidget {
  const DocumentTreeExplorerWeb({super.key});

  @override
  _DocumentTreeExplorerWebState createState() =>
      _DocumentTreeExplorerWebState();
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

  void _onNodeSelected(TreeNode<Explorable> node) {
    setState(() {
      _selectedNode = node;
    });
  }

  Future<void> _createFolder() async {
    if (_selectedNode?.data is Folder) {
      final folderName = await _promptFolderName();
      if (folderName == null || folderName.isEmpty) return;

      try {
        final folder = _selectedNode!.data as Folder;
        final newFolderId =
        await _apiService.createFolder(folder.id, folderName);

        setState(() {
          _selectedNode!.add(TreeNode<Explorable>(
            data: Folder(newFolderId, folderName),
          ));
        });

        _showMessage('Carpeta "$folderName" creada exitosamente.');
      } catch (e) {
        _showMessage('Error al crear la carpeta: $e', isError: true);
      }
    }
  }

  Future<String?> _promptFolderName() async {
    String folderName = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nueva Carpeta'),
          content: TextField(
            onChanged: (value) => folderName = value,
            decoration: const InputDecoration(hintText: 'Nombre de la carpeta'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.pop(context, folderName),
                child: const Text('Crear')),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    if (_selectedNode?.data is Folder) {
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
              final folder = _selectedNode!.data as Folder;

              await _apiService.uploadFileWeb(bytes, fileName, folder.id);

              setState(() {
                _selectedNode!.add(TreeNode<Explorable>(
                  data: File(
                    DateTime.now().millisecondsSinceEpoch,
                    fileName,
                    mimeType: 'application/octet-stream',
                    path: '',
                  ),
                ));
              });

              _showMessage('Archivo "$fileName" subido con éxito.');
            });
          }
        });
      } catch (e) {
        _showMessage('Error al subir archivo: $e', isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> _downloadFile() async {
    if (_selectedNode?.data is File) {
      final file = _selectedNode!.data as File;

      try {
        await _apiService.downloadFileWeb(file.id, file.name);
        _showMessage('Archivo "${file.name}" descargado con éxito.');
      } catch (e) {
        _showMessage('Error al descargar el archivo: $e', isError: true);
      }
    }
  }

  Future<void> _deleteSelectedNode() async {
    if (_selectedNode == null) return;

    final isFolder = _selectedNode!.data is Folder;
    final confirm = await _confirmDelete(isFolder);

    if (confirm) {
      try {
        await _apiService.deleteDocument(_selectedNode!.data!.id);
        setState(() {
          _selectedNode!.parent?.remove(_selectedNode!);
          _selectedNode = null;
        });

        _showMessage('${isFolder ? "Carpeta" : "Archivo"} eliminado con éxito.');
      } catch (e) {
        _showMessage('Error al eliminar: $e', isError: true);
      }
    }
  }

  Future<bool> _confirmDelete(bool isFolder) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ${isFolder ? "Carpeta" : "Archivo"}'),
        content: const Text('¿Estás seguro de que quieres eliminar este elemento?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorador de Documentos')),
      body: Row(
        children: [
          // Árbol de Documentos
          Container(
            width: 350,
            color: Colors.white,
            child: FutureBuilder<TreeNode<Explorable>>(
              future: _treeFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final tree = snapshot.data!;
                return TreeView.simpleTyped<Explorable, TreeNode<Explorable>>(
                  tree: tree,
                  showRootNode: false,
                  builder: (_, node) {
                    final isSelected = _selectedNode == node; // Verifica si este nodo está seleccionado
                    return ListTile(
                      tileColor: isSelected ? Colors.blue.withOpacity(0.5) : null, // Fondo resaltado
                      leading: Icon(
                        node.data is Folder
                            ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                            : Icons.insert_drive_file,
                        color: isSelected
                            ? Colors.blueAccent // Ícono resaltado
                            : node.data is Folder
                            ? Colors.orangeAccent
                            : Colors.lightBlueAccent,
                      ),
                      title: Text(
                        node.data!.name,
                        style: TextStyle(
                          color: isSelected ? Colors.blueAccent : null, // Texto resaltado
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedNode = node; // Actualiza el nodo seleccionado
                        });
                      },
                    );
                  },


                );
              },
            ),
          ),
          // Visualizador
          Expanded(
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  if (_selectedNode?.data != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          // Nombre del nodo seleccionado
                          Text(
                            _selectedNode!.data!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 20), // Espacio entre el nombre y los botones

                          // Botones dinámicos
                          if (_selectedNode?.data is Folder) ...[
                            ElevatedButton.icon(
                              onPressed: _createFolder,
                              icon: const Icon(Icons.create_new_folder),
                              label: const Text('Crear Carpeta'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _uploadFile,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Subir Documento'),
                            ),
                          ],
                          if (_selectedNode?.data is File)
                            ElevatedButton.icon(
                              onPressed: _downloadFile,
                              icon: const Icon(Icons.download),
                              label: const Text('Descargar'),
                            ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _deleteSelectedNode,
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
