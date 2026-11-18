class Pelicula {
  final String? id;
  final String titulo;
  final String anio;
  final String director;
  final String genero;
  final String sinopsis;
  final String imagenUrl;

  Pelicula({
    this.id,
    required this.titulo,
    required this.anio,
    required this.director,
    required this.genero,
    required this.sinopsis,
    required this.imagenUrl,
  });

  factory Pelicula.fromJson(String id, Map<String, dynamic> json) {
    return Pelicula(
      id: id,
      titulo: json['titulo'] ?? 'Sin título',
      anio: json['anio'] ?? 'N/A',
      director: json['director'] ?? 'Desconocido',
      genero: json['genero'] ?? 'General',
      sinopsis: json['sinopsis'] ?? 'Sin sinopsis disponible.',
      imagenUrl: json['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'anio': anio,
      'director': director,
      'genero': genero,
      'sinopsis': sinopsis,
      'imagenUrl': imagenUrl,
    };
  }
}