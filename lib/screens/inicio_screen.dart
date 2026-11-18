import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'catalogo_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();

  bool _esRegistro = false;
  bool _cargando = false;

  Future<void> _procesarAcceso() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      _mostrarMensaje('Por favor ingresa usuario y contraseña.', esError: true);
      return;
    }

    setState(() => _cargando = true);

    if (_esRegistro) {
      final registrado = await _firebaseService.registrarUsuario(usuario, password);
      if (!mounted) return;
      setState(() => _cargando = false);

      if (registrado) {
        _mostrarMensaje('¡Usuario registrado! Bienvenido, $usuario.');
        _irAlCatalogo(usuario);
      } else {
        _mostrarMensaje('No se pudo registrar (el usuario ya existe o hubo error de red).', esError: true);
      }
    } else {
      final valido = await _firebaseService.iniciarSesion(usuario, password);
      if (!mounted) return;
      setState(() => _cargando = false);

      if (valido) {
        _irAlCatalogo(usuario);
      } else {
        _mostrarMensaje('Usuario o contraseña incorrectos.', esError: true);
      }
    }
  }

  void _irAlCatalogo(String usuario) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogoScreen(usuarioActual: usuario),
      ),
    );
  }

  void _mostrarMensaje(String texto, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF311042)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.movie_filter_rounded,
                        size: 64,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Bienvenido a CineCatálogo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _esRegistro
                            ? 'Crea una cuenta nueva para explorar el catálogo'
                            : 'Ingresa con tu cuenta para ver las películas',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de usuario',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _procesarAcceso,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            _esRegistro ? 'Registrarme e Ingresar' : 'Iniciar Sesión',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () => setState(() => _esRegistro = !_esRegistro),
                        child: Text(
                          _esRegistro
                              ? '¿Ya tienes cuenta? Inicia sesión aquí'
                              : '¿Eres nuevo? Regístrate aquí',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}