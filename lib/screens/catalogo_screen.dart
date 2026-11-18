import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../services/firebase_service.dart';
import 'admin_screen.dart';
import 'detalle_pelicula_screen.dart';
import 'inicio_screen.dart';

class CatalogoScreen extends StatefulWidget {
  final String usuarioActual;

  const CatalogoScreen({super.key, required this.usuarioActual});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _firebaseService = FirebaseService();
  late Future<List<Pelicula>> _peliculasFuture;

  @override
  void initState() {
    super.initState();
    _recargarCatalogo();
  }

  void _recargarCatalogo() {
    setState(() {
      _peliculasFuture = _firebaseService.obtenerPeliculas();
    });
  }

  Future<void> _abrirAdministracion() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminScreen()),
    );
    _recargarCatalogo();
  }

  void _cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Películas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            tooltip: 'Menú principal',
            onSelected: (opcion) {
              if (opcion == 'catalogo') {
                _recargarCatalogo();
              } else if (opcion == 'admin') {
                _abrirAdministracion();
              } else if (opcion == 'salir') {
                _cerrarSesion();
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
              const PopupMenuItem(
                value: 'admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Administración (Altas / Bajas)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'salir',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.deepPurple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usuario: ${widget.usuarioActual}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _abrirAdministracion,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Administrar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pelicula>>(
              future: _peliculasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 50, color: Colors.red),
                        const SizedBox(height: 12),
                        const Text('Error al cargar el catálogo desde Firebase.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _recargarCatalogo,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final peliculas = snapshot.data ?? [];
                if (peliculas.isEmpty) {
                  return const Center(
                    child: Text('No hay películas disponibles en el catálogo.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _recargarCatalogo(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: peliculas.length,
                    itemBuilder: (context, index) {
                      final peli = peliculas[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetallePeliculaScreen(pelicula: peli),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Image.network(
                                  peli.imagenUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.movie_creation_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  peli.titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}