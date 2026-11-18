import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../services/firebase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _firebaseService = FirebaseService();
  final _tituloController = TextEditingController();
  final _anioController = TextEditingController();
  final _directorController = TextEditingController();
  final _generoController = TextEditingController();
  final _sinopsisController = TextEditingController();
  final _imagenUrlController = TextEditingController();

  List<Pelicula> _peliculas = [];
  bool _cargandoLista = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  Future<void> _cargarPeliculas() async {
    setState(() => _cargandoLista = true);
    try {
      final lista = await _firebaseService.obtenerPeliculas();
      if (!mounted) return;
      setState(() {
        _peliculas = lista;
        _cargandoLista = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargandoLista = false);
    }
  }

  Future<void> _darDeAlta() async {
    if (_tituloController.text.trim().isEmpty ||
        _anioController.text.trim().isEmpty ||
        _directorController.text.trim().isEmpty ||
        _generoController.text.trim().isEmpty ||
        _sinopsisController.text.trim().isEmpty ||
        _imagenUrlController.text.trim().isEmpty) {
      _notificar('Completa todos los campos para registrar la película.', esError: true);
      return;
    }

    setState(() => _guardando = true);

    final nueva = Pelicula(
      titulo: _tituloController.text.trim(),
      anio: _anioController.text.trim(),
      director: _directorController.text.trim(),
      genero: _generoController.text.trim(),
      sinopsis: _sinopsisController.text.trim(),
      imagenUrl: _imagenUrlController.text.trim(),
    );

    final ok = await _firebaseService.agregarPelicula(nueva);
    if (!mounted) return;
    setState(() => _guardando = false);

    if (ok) {
      _tituloController.clear();
      _anioController.clear();
      _directorController.clear();
      _generoController.clear();
      _sinopsisController.clear();
      _imagenUrlController.clear();
      _notificar('Película agregada correctamente a Firebase.');
      _cargarPeliculas();
    } else {
      _notificar('Error al guardar la película en Firebase.', esError: true);
    }
  }

  Future<void> _darDeBaja(Pelicula pelicula) async {
    if (pelicula.id == null) return;
    final ok = await _firebaseService.eliminarPelicula(pelicula.id!);
    if (!mounted) return;

    if (ok) {
      _notificar('Película "${pelicula.titulo}" eliminada.');
      _cargarPeliculas();
    } else {
      _notificar('No se pudo eliminar la película.', esError: true);
    }
  }

  void _notificar(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _anioController.dispose();
    _directorController.dispose();
    _generoController.dispose();
    _sinopsisController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
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
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Alta de Película'),
              Tab(icon: Icon(Icons.delete_outline), text: 'Baja de Películas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // PESTAÑA 1: ALTA
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _campoTexto(_tituloController, 'Título de la película', Icons.title),
                  _campoTexto(_anioController, 'Año de estreno', Icons.calendar_today, esNumero: true),
                  _campoTexto(_directorController, 'Director', Icons.person),
                  _campoTexto(_generoController, 'Género cinematográfico', Icons.category),
                  _campoTexto(_sinopsisController, 'Sinopsis', Icons.description, maxLineas: 3),
                  _campoTexto(_imagenUrlController, 'URL de la imagen (póster)', Icons.image),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _darDeAlta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.save),
                      label: Text(_guardando ? 'Guardando...' : 'Guardar en Catálogo'),
                    ),
                  ),
                ],
              ),
            ),
            // PESTAÑA 2: BAJA
            _cargandoLista
                ? const Center(child: CircularProgressIndicator())
                : _peliculas.isEmpty
                ? const Center(child: Text('No hay películas registradas.'))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _peliculas.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final peli = _peliculas[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      peli.imagenUrl,
                      width: 45,
                      height: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.movie, size: 40),
                    ),
                  ),
                  title: Text(
                    peli.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${peli.anio} • ${peli.director}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Dar de baja',
                    onPressed: () => _darDeBaja(peli),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool esNumero = false,
        int maxLineas = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        keyboardType: esNumero ? TextInputType.number : TextInputType.text,
        maxLines: maxLineas,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}