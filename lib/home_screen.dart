import 'dart:async';
import 'package:aplicacion2/productos.dart';
import 'package:flutter/material.dart';
import 'package:aplicacion2/db_helper.dart';
import 'package:aplicacion2/main.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = true;
  Timer? _inactividadTimer;
  int? _selectedRol;

  // Lista de roles para el menú desplegable
  final List<DropdownMenuItem<int>> _rolOption = [
    DropdownMenuItem<int>(value: 1, child: Text("1")),
    DropdownMenuItem<int>(value: 2, child: Text("2")),
  ];

  void _refreshUser() async {
    final user = await SQLHelper.getAllUser();
    setState(() {
      _allUser = user;
      _isLoading = false;
    });
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Notificación de inactividad
  void _showInactividadNotification() {
    final snackBar = SnackBar(
      content: Text("Estás inactivo. Se cerrará sesión en 5 segundos."),
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Cerrar',
        onPressed: () {
          _inactividadTimer?.cancel();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Actividad en la pantalla
  void _resetInactividadTimer() {
    _inactividadTimer?.cancel();
    _inactividadTimer = Timer(Duration(seconds: 20), () {
      _showInactividadNotification();
      _inactividadTimer = Timer(Duration(seconds: 15), cerrarSesion);
    });
  }

  void _handleUserInteraction([_]) {
    _resetInactividadTimer();
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
    _resetInactividadTimer();
  }

  @override
  void dispose() {
    _inactividadTimer?.cancel();
    super.dispose();
  }

  final TextEditingController _usuarioEditingController = TextEditingController();
  final TextEditingController _contEditingController = TextEditingController();
  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _correoEditingController = TextEditingController();

  Future<void> _addUser() async {
    try {
      await SQLHelper.createUser(
        _usuarioEditingController.text,
        _contEditingController.text,
        _nombreEditingController.text,
        _correoEditingController.text,
        _selectedRol ?? 1,
      );
      _refreshUser();
    } catch (e) {
      print("Error al agregar usuario: $e");
    }
  }

  Future<void> _updateUser(int id) async {
    try {
      await SQLHelper.updateUser(
        id,
        _usuarioEditingController.text,
        _contEditingController.text,
        _nombreEditingController.text,
        _correoEditingController.text,
        _selectedRol ?? 1,
      );
      _refreshUser();
    } catch (e) {
      print("Error al actualizar usuario: $e");
    }
  }

  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Registro eliminado"),
    ));
    _refreshUser();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingUser = _allUser.firstWhere((element) => element['id'] == id);
      _usuarioEditingController.text = existingUser['usuario'];
      _contEditingController.text = existingUser['cont'];
      _nombreEditingController.text = existingUser['nombre'];
      _correoEditingController.text = existingUser['correo'];
      _selectedRol = existingUser['rol'];
    } else {
      _usuarioEditingController.text = "";
      _contEditingController.text = "";
      _nombreEditingController.text = "";
      _correoEditingController.text = "";
      _selectedRol = null;
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _usuarioEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Usuario",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contEditingController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Contraseña",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nombreEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombres",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _correoEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Correo",
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedRol,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Rol",
              ),
              items: _rolOption,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedRol = newValue;
                });
              },
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedRol == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text("Por favor selecciona un rol."),
                      ),
                    );
                    return;
                  }

                  if (id == null) {
                    await _addUser();
                  } else {
                    await _updateUser(id);
                  }
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Usuario" : "Actualizar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('home-screen'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          _inactividadTimer?.cancel();
        } else {
          _resetInactividadTimer();
        }
      },
      child: Listener(
        onPointerDown: _handleUserInteraction,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: _handleUserInteraction,
          onTap: _handleUserInteraction,
          onScaleStart: _handleUserInteraction,
          child: Scaffold(
            backgroundColor: Color(0xFFECEAF4),
            appBar: AppBar(
              title: Text("Usuarios"),
              actions: [
                IconButton(
                  icon: Icon(Icons.shopping_cart), // Cambia el icono según sea necesario
                  onPressed: () {
                    // Navegar a la pantalla de productos
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Product()), // Asegúrate de que ProductScreen está definido
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: cerrarSesion,
                ),
              ],
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _allUser.length,
                          itemBuilder: (context, index) => Card(
                            margin: EdgeInsets.all(15),
                            child: ListTile(
                              title: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  _allUser[index]['usuario'],
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_allUser[index]['nombre'].toString()),
                                  Text(_allUser[index]['correo'].toString()),
                                  Text(_allUser[index]['cont'].toString()),
                                  Text("Rol: ${_allUser[index]['rol']}"),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () => muestraDatos(_allUser[index]['id']),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteUser(_allUser[index]['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => muestraDatos(null),
                        child: Text("Agregar Usuario"),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
