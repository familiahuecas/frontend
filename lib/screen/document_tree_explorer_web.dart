  import 'dart:html' as html; // Exclusivo para web
  import 'dart:typed_data';
  import 'package:animated_tree_view/animated_tree_view.dart';
  import 'package:flutter/material.dart';
  import 'package:path_provider/path_provider.dart';

  import '../../../apirest/api_service.dart';
  import '../../../model/exportable.dart';

  import '../../../screen/widget/PDFViewerScreen.dart';
  import 'dart:io' as io; // Alias para evitar conflicto


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
    String? _fileContent; // Almacena el contenido descargado
    Uint8List? _fileBytes; // Para manejar archivos binarios como imágenes
    bool _isLoading = false;

    String? _pdfUrl; // URL del blob para visualizar PDFs
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
        _selectedNode = node; // Actualiza el nodo seleccionado
      });

      // Si el nodo seleccionado es un archivo, llama al método de visualización
      if (node.data is File) {
        _viewSelectedFile(node.data as File);
      }
    }


    Future<void> _createFolder() async {
      if (_selectedNode?.data is Folder) {
        final folderName = await _promptFolderName();
        if (folderName == null || folderName.isEmpty) return;

        try {
          final folder = _selectedNode!.data as Folder;
          final newFolderId = await _apiService.createFolder(folder.id, folderName);

          // Agregar la nueva carpeta al árbol en memoria
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
              final file = files[0];
              print('Archivo seleccionado: ${file.name}');
              print('Tamaño del archivo: ${file.size} bytes');
              print('Tipo MIME detectado por el navegador: ${file.type.isEmpty ? "No especificado" : file.type}');

              if (file.size == 0) {
                _showMessage('El archivo está vacío y no puede ser leído.', isError: true);
                return;
              }

              final reader = html.FileReader();
              reader.readAsArrayBuffer(file);

              reader.onLoadEnd.listen((_) async {
                if (reader.result != null) {
                  try {
                    Uint8List bytes;
                    if (reader.result is Uint8List) {
                      bytes = reader.result as Uint8List;
                    } else if (reader.result is ByteBuffer) {
                      bytes = Uint8List.view(reader.result as ByteBuffer);
                    } else {
                      throw Exception('Formato de archivo no compatible: ${reader.result.runtimeType}');
                    }

                    final folder = _selectedNode!.data as Folder;
                    await _apiService.uploadFileWeb(bytes, file.name, folder.id);

                    // Agregar el nuevo archivo al nodo actual del árbol
                    setState(() {
                      _selectedNode!.add(TreeNode<Explorable>(
                        data: File(
                          DateTime.now().millisecondsSinceEpoch,
                          file.name,
                          mimeType: file.type.isEmpty ? 'application/octet-stream' : file.type,
                          path: '',
                        ),
                      ));
                    });

                    _showMessage('Archivo "${file.name}" subido con éxito.');
                  } catch (e) {
                    _showMessage('Error al procesar el archivo: $e', isError: true);
                  }
                } else {
                  _showMessage('No se pudo leer el archivo.', isError: true);
                }
              });

              reader.onError.listen((_) {
                _showMessage('Error al leer el archivo.', isError: true);
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
                      final isSelected = _selectedNode == node; // Nodo seleccionado
                      return ListTile(
                        tileColor: isSelected ? Colors.blue.withOpacity(0.5) : null, // Fondo resaltado
                        leading: Icon(
                          node.data is Folder
                              ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                              : Icons.insert_drive_file,
                          color: node.data is Folder
                              ? Colors.orangeAccent // Carpetas
                              : Colors.lightBlueAccent, // Archivos
                        ),
                        title: Text(
                          node.data!.name,
                          style: TextStyle(
                            color: isSelected ? Colors.blueAccent : Colors.black, // Texto resaltado
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedNode = node; // Actualiza el nodo seleccionado
                            _onNodeSelected(node);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedNode?.data != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nombre del nodo seleccionado
                          Text(
                            _selectedNode!.data!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Botones dinámicos
                          Row(
                            children: [
                              if (_selectedNode?.data is Folder) ...[
                                ElevatedButton.icon(
                                  onPressed: _createFolder, // Lógica para crear una carpeta
                                  icon: const Icon(Icons.create_new_folder),
                                  label: const Text('Crear Carpeta'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: _uploadFile, // Lógica para adjuntar archivo
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Adjuntar Archivo'),
                                ),
                              ],
                              if (_selectedNode?.data is File) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _viewSelectedFile(_selectedNode!.data as File), // Pasa el archivo seleccionado
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Examinar'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _downloadFile, // Lógica para descargar
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download'),
                                ),
                              ],
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: _deleteSelectedNode, // Lógica para eliminar
                                icon: const Icon(Icons.delete),
                                label: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const Divider(),
                    // Área de visualización
                    Expanded(
                      child: Container(
                        color: Colors.grey[200], // Fondo del área del visor
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center, // Centra el contenedor
                        child: Column(
                          children: [
                            // Botones de navegación
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 32, // Tamaño más grande
                                    color: Colors.blue, // Color personalizado
                                  ),
                                  tooltip: 'Anterior',
                                  onPressed: _navigateToPreviousFile,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.blue.withOpacity(0.1), // Fondo ligero
                                    shape: CircleBorder(), // Forma circular
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward,
                                    size: 32, // Tamaño más grande
                                    color: Colors.green, // Color personalizado
                                  ),
                                  tooltip: 'Siguiente',
                                  onPressed: _navigateToNextFile,
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.withOpacity(0.1), // Fondo ligero
                                    shape: CircleBorder(), // Forma circular
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10), // Espacio entre los botones y el visor

                            // Contenedor del visor
                            Expanded(
                              child: Container(
                                width: 800, // Ancho fijo del contenedor
                                height: 600, // Alto fijo del contenedor
                                decoration: BoxDecoration(
                                  color: Colors.white, // Fondo del contenido
                                  borderRadius: BorderRadius.circular(8), // Esquinas redondeadas
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26, // Sombra ligera
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: _isLoading
                                    ? const Center(
                                  child: CircularProgressIndicator(), // Indicador de carga
                                )
                                    : _pdfUrl != null
                                    ? HtmlElementView(
                                  viewType: 'pdf-viewer',
                                  onPlatformViewCreated: (int viewId) {
                                    final iframe = html.IFrameElement()
                                      ..src = _pdfUrl
                                      ..style.border = 'none'
                                      ..width = '100%'
                                      ..height = '100%';

                                    // Agrega el iframe al contenedor
                                    html.document.getElementById('pdf-viewer')?.append(iframe);
                                  },
                                )
                                    : _fileContent != null
                                    ? SingleChildScrollView(
                                  child: Text(
                                    _fileContent!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                )
                                    : _fileBytes != null
                                    ? Center(
                                  child: Image.memory(
                                    _fileBytes!,
                                    fit: BoxFit.none, // Mantiene el tamaño original
                                    alignment: Alignment.center,
                                  ),
                                )
                                    : const Center(
                                  child: Text('Seleccione un archivo para visualizar.'),
                                ),
                              ),
                            )

                          ],
                        ),
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



    void viewPDFWebInline(Uint8List fileData, String fileName) {
      // Crea un blob con los datos del PDF
      final blob = html.Blob([fileData], 'application/pdf');

      // Crea una URL temporal para el blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      setState(() {
        _pdfUrl = url; // Guarda la URL del PDF para usarla en el iframe
      });

      // Opcional: Revoca la URL después de un tiempo para liberar memoria
      Future.delayed(const Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
    }


    Future<void> _viewSelectedFile(File file) async {
      try {
        // Llama al servicio para obtener los datos del archivo
        final fileData = await _apiService.fetchFileContent(file.id);
     // print(file.mimeType);
        if (['.pdf']
            .any((ext) => file.name.toLowerCase().endsWith(ext))) {
          // Manejo específico para PDFs
          setState(() {
            _fileContent = null;
            _fileBytes = null; // Limpia cualquier contenido previo
          });

          // Cambia el estado del visor para mostrar el PDF
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: PDFViewerWeb(pdfData: fileData),
            ),
          );
        } else if ([
          '.txt', // Texto simple
          '.csv', // Texto delimitado por comas
          '.log', // Archivos de log
          '.json', // JSON
          '.xml', // XML
          '.html', // HTML
          '.htm', // HTML alternativo
          '.js', // JavaScript
          '.css', // CSS
          '.yaml', // YAML
          '.yml', // YAML alternativo
          '.md', // Markdown
          '.sql', // SQL scripts
          '.sh', // Shell scripts
          '.bat', // Batch scripts
          '.ini', // Configuración INI
          '.conf', // Configuración general
          '.properties', // Configuración Java
          '.java', // Código fuente Java
          '.py', // Código fuente Python
          '.c', // Código fuente C
          '.cpp', // Código fuente C++
          '.cs', // Código fuente C#
          '.dart', // Código fuente Dart
          '.rb', // Código fuente Ruby
          '.php', // Código fuente PHP
          '.pl', // Código fuente Perl
          '.rs', // Código fuente Rust
          '.swift', // Código fuente Swift
          '.go', // Código fuente Go
          '.ts', // Código fuente TypeScript
          '.tsx', // Código fuente TypeScript React
          '.jsx', // Código fuente JavaScript React
          '.r', // Código fuente R
          '.kt', // Código fuente Kotlin
          '.scala', // Código fuente Scala
          '.groovy', // Código fuente Groovy
          '.gradle', // Scripts de Gradle
          '.m', // Código fuente Objective-C
          '.h', // Headers C/C++
        ].any((ext) => file.name.toLowerCase().endsWith(ext))) {
          // Lógica para archivos de texto
          setState(() {
            _fileContent = String.fromCharCodes(fileData);
            _fileBytes = null; // Limpia cualquier dato binario
            _pdfUrl = null; // Limpia la URL del PDF si no es un PDF
          });
        }
        else if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.tif', '.webp']
            .any((ext) => file.name.toLowerCase().endsWith(ext))) {
          setState(() {
            _fileBytes = fileData;
            _fileContent = null;
            _pdfUrl = null; // Limpia la URL del PDF si no es un PDF
          });
        } else {
          _showMessage('Formato no soportado para vista previa.', isError: true);
        }
      } catch (e) {
        _showMessage('Error al descargar el archivo: $e', isError: true);
      }
    }


    void _navigateToNextFile() {
      if (_selectedNode?.parent == null) return; // Verifica que hay un nodo seleccionado

      final siblings = _selectedNode!.parent?.children.values.toList() ?? <TreeNode<Explorable>>[];
      final currentIndex = siblings.indexOf(_selectedNode!);

      if (currentIndex != -1 && currentIndex < siblings.length - 1) {
        final nextNode = siblings[currentIndex + 1];

        if (nextNode is TreeNode<Explorable>) {
          setState(() {
            _selectedNode = nextNode; // Actualiza el nodo seleccionado
          });

          if (nextNode.data is File) {
            _viewSelectedFile(nextNode.data as File);
          }
        }
      }
    }

    void _navigateToPreviousFile() {
      if (_selectedNode?.parent == null) return; // Verifica que hay un nodo seleccionado

      final siblings = _selectedNode!.parent?.children.values.toList() ?? <TreeNode<Explorable>>[];
      final currentIndex = siblings.indexOf(_selectedNode!);

      if (currentIndex > 0) {
        final previousNode = siblings[currentIndex - 1];

        if (previousNode is TreeNode<Explorable>) {
          setState(() {
            _selectedNode = previousNode; // Actualiza el nodo seleccionado
          });

          if (previousNode.data is File) {
            _viewSelectedFile(previousNode.data as File);
          }
        }
      }
    }


  }
