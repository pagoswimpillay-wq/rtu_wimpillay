import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_service.dart'; // ✅ IMPORTANTE: Agregar esta importación

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTU Wimpillay - Usuarios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gestión de Usuarios - RTU Wimpillay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Controladores para los campos de texto
  final TextEditingController _controllerDNI = TextEditingController();
  final TextEditingController _controllerNombre = TextEditingController();

  // Future para almacenar la lista de usuarios
  late Future<List<Map<String, dynamic>>> listaUsuarios;

  @override
  void initState() {
    super.initState();
    // Al iniciar, cargar la lista de usuarios
    listaUsuarios = obtenerUsuarios(); // ✅ Ahora está definido
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: listaUsuarios,
        builder: (context, snapshot) {
          // Estado: Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando usuarios...'),
                ],
              ),
            );
          } 
          // Estado: Error
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar usuarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _recargarUsuarios,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } 
          // Estado: Datos cargados correctamente
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final usuario = snapshot.data![index];
                final dni = usuario['dni'] ?? 'Sin DNI';
                final nombre = usuario['nombre'] ?? 'Sin nombre';
                final uid = usuario['uid'] ?? '';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("DNI: $dni"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _mostrarDialogoEliminar(uid, nombre);
                    },
                  ),
                  onTap: () {
                    _mostrarDialogoEditar(uid, dni, nombre);
                  },
                );
              },
            );
          } 
          // Estado: No hay datos
          else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay usuarios registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Presiona el botón + para agregar el primer usuario',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        tooltip: 'Agregar Usuario',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Recarga la lista de usuarios
  void _recargarUsuarios() {
    setState(() {
      listaUsuarios = obtenerUsuarios(); // ✅ Definido
    });
  }

  /// Muestra diálogo para agregar un nuevo usuario
  void _mostrarDialogoAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controllerDNI,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  hintText: 'Ingrese el DNI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controllerNombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ingrese el nombre completo',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarCampos();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dni = _controllerDNI.text.trim();
                final nombre = _controllerNombre.text.trim();

                if (dni.isEmpty || nombre.isEmpty) {
                  _mostrarMensajeError('Por favor complete todos los campos');
                  return;
                }

                try {
                  await agregarUsuario(dni, nombre); // ✅ Definido
                  Navigator.of(context).pop();
                  _limpiarCampos();
                  _recargarUsuarios();
                  _mostrarMensajeExito('Usuario agregado correctamente');
                } catch (e) {
                  _mostrarMensajeError('Error al agregar usuario: $e');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo para editar un usuario existente
  void _mostrarDialogoEditar(String uid, String dniActual, String nombreActual) {
    final controllerDNI = TextEditingController(text: dniActual);
    final controllerNombre = TextEditingController(text: nombreActual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controllerDNI,
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controllerNombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevoDNI = controllerDNI.text.trim();
                final nuevoNombre = controllerNombre.text.trim();

                if (nuevoDNI.isEmpty || nuevoNombre.isEmpty) {
                  _mostrarMensajeError('Por favor complete todos los campos');
                  return;
                }

                try {
                  await actualizarUsuario(uid, nuevoDNI, nuevoNombre); // ✅ Definido
                  Navigator.of(context).pop();
                  _recargarUsuarios();
                  _mostrarMensajeExito('Usuario actualizado correctamente');
                } catch (e) {
                  _mostrarMensajeError('Error al actualizar usuario: $e');
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra diálogo de confirmación para eliminar usuario
  void _mostrarDialogoEliminar(String uid, String nombre) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de eliminar al usuario "$nombre"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await eliminarUsuario(uid); // ✅ Definido
                  _recargarUsuarios();
                  _mostrarMensajeExito('Usuario eliminado correctamente');
                } catch (e) {
                  _mostrarMensajeError('Error al eliminar usuario: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un mensaje de éxito
  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un mensaje de error
  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Limpia los campos de texto
  void _limpiarCampos() {
    _controllerDNI.clear();
    _controllerNombre.clear();
  }

  @override
  void dispose() {
    // Limpiar los controladores cuando el widget se destruya
    _controllerDNI.dispose();
    _controllerNombre.dispose();
    super.dispose();
  }
}
