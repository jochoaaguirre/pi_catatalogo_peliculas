import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pelicula.dart';

class FirebaseService {
  static const String _baseUrl =
      'https://catalogo-peliculas-jochoaa-default-rtdb.firebaseio.com';

  // --- AUTENTICACIÓN DE USUARIOS (HTTP GET & POST) ---

  Future<bool> registrarUsuario(String usuario, String password) async {
    final url = Uri.parse('$_baseUrl/usuarios.json');
    try {
      final getResponse = await http.get(url);
      if (getResponse.statusCode == 200 && getResponse.body != 'null') {
        final Map<String, dynamic> data = json.decode(getResponse.body);
        final existe = data.values.any(
              (u) => u['usuario'].toString().toLowerCase() == usuario.toLowerCase(),
        );
        if (existe) return false; // El usuario ya existe
      }

      final postResponse = await http.post(
        url,
        body: json.encode({
          'usuario': usuario.trim(),
          'password': password.trim(),
        }),
      );
      return postResponse.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> iniciarSesion(String usuario, String password) async {
    final url = Uri.parse('$_baseUrl/usuarios.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != 'null') {
        final Map<String, dynamic> data = json.decode(response.body);
        for (var entry in data.values) {
          if (entry['usuario'] == usuario.trim() &&
              entry['password'] == password.trim()) {
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // --- GESTIÓN DE PELÍCULAS (HTTP GET, POST, DELETE) ---

  Future<List<Pelicula>> obtenerPeliculas() async {
    final url = Uri.parse('$_baseUrl/peliculas.json');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al conectar con Firebase');
    }

    // Si la base está vacía, cargamos 3 películas iniciales automáticamente
    if (response.body == 'null') {
      await _cargarPeliculasIniciales();
      final retry = await http.get(url);
      if (retry.body == 'null') return [];
      final Map<String, dynamic> retryData = json.decode(retry.body);
      return retryData.entries
          .map((e) => Pelicula.fromJson(e.key, Map<String, dynamic>.from(e.value)))
          .toList();
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return data.entries
        .map((e) => Pelicula.fromJson(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
  }

  Future<bool> agregarPelicula(Pelicula pelicula) async {
    final url = Uri.parse('$_baseUrl/peliculas.json');
    final response = await http.post(
      url,
      body: json.encode(pelicula.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarPelicula(String id) async {
    final url = Uri.parse('$_baseUrl/peliculas/$id.json');
    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  Future<void> _cargarPeliculasIniciales() async {
    final iniciales = [
      Pelicula(
        titulo: 'Interestelar',
        anio: '2014',
        director: 'Christopher Nolan',
        genero: 'Ciencia Ficción',
        sinopsis:
        'Un grupo de exploradores viaja a través de un agujero de gusano en el espacio en un intento por asegurar la supervivencia de la humanidad.',
        imagenUrl:
        'https://upload.wikimedia.org/wikipedia/en/b/bc/Interstellar_film_poster.jpg',
      ),
      Pelicula(
        titulo: 'El Origen (Inception)',
        anio: '2010',
        director: 'Christopher Nolan',
        genero: 'Acción / Ciencia Ficción',
        sinopsis:
        'A un ladrón que roba secretos corporativos a través de la tecnología de compartir sueños se le encomienda la tarea inversa de implantar una idea.',
        imagenUrl:
        'https://upload.wikimedia.org/wikipedia/en/2/2e/Inception_%282010%29_theatrical_poster.jpg',
      ),
      Pelicula(
        titulo: 'Matrix',
        anio: '1999',
        director: 'Lana y Lilly Wachowski',
        genero: 'Ciencia Ficción / Acción',
        sinopsis:
        'Un programador informático descubre que la realidad que percibe es una simulación creada por máquinas y se une a la rebelión.',
        imagenUrl:
        'https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg',
      ),
    ];

    for (var peli in iniciales) {
      await agregarPelicula(peli);
    }
  }
}