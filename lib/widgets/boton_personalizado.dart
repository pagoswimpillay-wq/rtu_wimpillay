import 'package:flutter/material.dart';

class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback accion;

  const BotonPersonalizado({
    super.key,
    required this.texto,
    required this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: accion,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.green,
      ),
      child: Text(texto, style: const TextStyle(fontSize: 18)),
    );
  }
}
