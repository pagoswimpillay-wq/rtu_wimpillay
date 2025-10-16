// Importaciones para Firestore
import 'package:cloud_firestore/cloud_firestore.dart';

// Instancia de Firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Colección de usuarios en Firestore
final CollectionReference _usuariosRef = _firestore.collection('usuarios');

// Método para obtener todos los usuarios
Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
  try {
    // Obtener snapshot de la colección
    QuerySnapshot snapshot = await _usuariosRef.get();
    
    // Mapear cada documento a un Map con los datos
    List<Map<String, dynamic>> usuarios = snapshot.docs.map((doc) {
      return {
        'uid': doc.id,  // ID del documento
        'dni': doc['dni'],  // Campo DNI
        'nombre': doc['nombre'],  // Campo nombre
      };
    }).toList();
    
    return usuarios;  // Retornar lista de usuarios
  } catch (e) {
    // En caso de error, retornar lista vacía
    print("Error al obtener usuarios: $e");
    return [];
  }
}

// Método para agregar un usuario
Future<void> agregarUsuario(String dni, String nombre) async {
  try {
    // Agregar documento a la colección
    await _usuariosRef.add({
      'dni': dni,  // Campo DNI
      'nombre': nombre,  // Campo nombre
      'fechaCreacion': FieldValue.serverTimestamp(),  // Fecha automática
    });
  } catch (e) {
    print("Error al agregar usuario: $e");
    throw e;  // Relanzar error
  }
}

// Método para eliminar un usuario
Future<void> eliminarUsuario(String uid) async {
  try {
    // Eliminar documento por UID
    await _usuariosRef.doc(uid).delete();
  } catch (e) {
    print("Error al eliminar usuario: $e");
    throw e;  // Relanzar error
  }
}

// Método para actualizar un usuario
Future<void> actualizarUsuario(String uid, String dni, String nombre) async {
  try {
    // Actualizar documento por UID
    await _usuariosRef.doc(uid).update({
      'dni': dni,  // Nuevo DNI
      'nombre': nombre,  // Nuevo nombre
      'fechaActualizacion': FieldValue.serverTimestamp(),  // Fecha de actualización
    });
  } catch (e) {
    print("Error al actualizar usuario: $e");
    throw e;  // Relanzar error
  }
}
