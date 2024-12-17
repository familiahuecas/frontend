import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../apirest/api_service.dart';
import '../model/exportable.dart';

class DocumentTreeScreenMobile extends StatefulWidget {
  const DocumentTreeScreenMobile({super.key});

  @override
  _DocumentTreeScreenMobileState createState() => _DocumentTreeScreenMobileState();
}

class _DocumentTreeScreenMobileState extends State<DocumentTreeScreenMobile> {
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

    // Trazas para depuración
    print('Datos recibidos del backend para el árbol documental:');
    for (var item in json) {
      print(item);
    }

    return _buildTreeFromJson(json);
  }


  TreeNode<Explorable> _buildTreeFromJson(List<Map<String, dynamic>> json) {
    final rootNode = TreeNode<Explorable>.root(data: Folder(-1, "/root"));

    // Trazas para depuración
    print('Construyendo el árbol documental desde JSON:');
    for (var item in json) {
      print('Nodo raíz, agregando hijo con ID: ${item['id']}, Nombre: ${item['nombre']}');
      rootNode.add(_buildNode(item));
    }

    return rootNode;
  }

  TreeNode<Explorable> _buildNode(Map<String, dynamic> json) {
    print('Construyendo nodo con datos: $json');
    if (json['esCarpeta'] == true) {
      final folderNode = TreeNode<Explorable>(
        data: Folder(json['id'], json['nombre']),
      );

      // Si tiene hijos, los agrega
      if (json['children'] != null) {
        for (var child in json['children']) {
          print('Nodo carpeta ID: ${json['id']} tiene hijo ID: ${child['id']}');
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
        final xFile = await openFile();

        if (xFile != null) {
          final bytes = await xFile.readAsBytes();
          final fileName = xFile.name;
          final parentId = (node.data as Folder).id;

          print('Subiendo archivo: $fileName, Tamaño: ${bytes.length}, Parent ID: $parentId');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subiendo archivo...')),
          );

          final response = await _apiService.uploadFileWeb(bytes, fileName, parentId);



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
        }
      } catch (e) {
        print('Error en la subida: $e');
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
                  final isRootNode = explorable is Folder && explorable.name == "Documentos"; // Verifica si es la carpeta raíz

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
                    trailing: isRootNode
                        ? null // No mostrar íconos para la carpeta raíz "Documentos"
                        : Row(
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
                          tooltip: 'Eliminar',
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
                          await _apiService.downloadFile(explorable.id, explorable.name);

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
                }


            ),
          );

        },
      ),
    );
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

    // Verificar si hay un nodo seleccionado
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
      return; // Detener la ejecución si no hay carpeta seleccionada
    }

    // Mostrar el diálogo para ingresar el nombre de la nueva carpeta
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

    // Verificar si se ingresó un nombre válido
    if (folderName != null && folderName.trim().isNotEmpty) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creando carpeta...')),
        );

        // Obtener el ID del nodo padre
        final parentId = (currentNode.data as Folder).id;
        print('Creando carpeta con nombre: $folderName, parentId: $parentId');

        // Llamar al servicio para crear la carpeta
        final newFolderId = await _apiService.createFolder(parentId, folderName);

        print('ID de la nueva carpeta creada: $newFolderId');

        // Agregar la nueva carpeta al árbol localmente
        final newFolder = Folder(newFolderId, folderName);
        currentNode.add(TreeNode<Explorable>(data: newFolder));

        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Carpeta creada correctamente.')),
          );
        });
      } catch (e) {
        print('Error al crear la carpeta: $e');
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


}
