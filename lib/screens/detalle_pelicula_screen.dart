import 'package:flutter/material.dart';
import '../models/pelicula.dart';

class DetallePeliculaScreen extends StatelessWidget {
  final Pelicula pelicula;

  const DetallePeliculaScreen({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Película'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú',
            onSelected: (value) {
              if (value == 'catalogo') {
                Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'catalogo',
                child: Row(
                  children: [
                    Icon(Icons.movie, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Catálogo de películas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  pelicula.imagenUrl,
                  height: 320,
                  width: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 320,
                    width: 220,
                    color: Colors.grey.shade300,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Imagen no disponible'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pelicula.titulo,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _datoFila(Icons.calendar_today, 'Año de estreno', pelicula.anio),
            _datoFila(Icons.person, 'Director', pelicula.director),
            _datoFila(Icons.category, 'Género cinematográfico', pelicula.genero),
            const Divider(height: 32),
            const Text(
              'Sinopsis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pelicula.sinopsis,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoFila(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$etiqueta: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}