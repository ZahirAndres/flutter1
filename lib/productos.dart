import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aplicacion2/db_helper.dart';
import 'package:aplicacion2/main.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Product extends StatefulWidget {
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<Map<String, dynamic>> _allProduct = [];
  bool _isLoading = true;
  Timer? _inactividadTimer;

  void _refreshProduct() async {
    final product = await SQLHelper.getAllProduct();
    setState(() {
      _allProduct = product;
      _isLoading = false;
    });
  }

  final TextEditingController _nombProductEditingController =  TextEditingController();
  final TextEditingController _precEditingController =  TextEditingController();
  final TextEditingController _cantidadProductEditingController =  TextEditingController();
  final TextEditingController _categoriaProductEditingController =  TextEditingController();

  

  Future<void> agregar() async{
    double precio = double.parse(_precEditingController.text);
    int cantidad = int.parse(_cantidadProductEditingController.text);
    await SQLHelper.agregar(_nombProductEditingController.text, precio, cantidad, _categoriaProductEditingController.text);
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
      content: Text("Estás inactivo. Se cerrará sesión en 3 minutos."),
      duration: Duration(minutes: 3),
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
      _inactividadTimer = Timer(Duration(minutes: 3), cerrarSesion);
    });
  }

  void _handleUserInteraction([_]) {
    _resetInactividadTimer();
  }

  @override
  void initState() {
    super.initState();
    _refreshProduct();
    _resetInactividadTimer();
  }

  @override
  void dispose() {
    _inactividadTimer?.cancel();
    super.dispose();
  }

  final TextEditingController _nombreProductEditingController =
      TextEditingController();
  final TextEditingController _precioEditingController =
      TextEditingController();
  final TextEditingController _cantEditingController = TextEditingController();
  final TextEditingController _imagenEditingController =
      TextEditingController();

  Future<void> _addProduct() async {
    double precio = double.parse(_precioEditingController.text);
    int cantidad = int.parse(_cantEditingController.text);
    try {
      await SQLHelper.createProduct(_nombreProductEditingController.text,
          precio, cantidad, _imagenEditingController.text);
      _refreshProduct();
    } catch (e) {
      print("Error al agregar producto: $e");
    }
  }

  Future<void> _updateProduct(int id) async {
    double precio = double.parse(_precioEditingController.text);
    int cantidad = int.parse(_cantEditingController.text);
    try {
      await SQLHelper.updateProduct(id, _nombreProductEditingController.text,
          precio, cantidad, _imagenEditingController.text);
      _refreshProduct();
    } catch (e) {
      print("Error al actualizar producto: $e");
    }
  }

  Future<void> _deleteProduct(int id) async {
    await SQLHelper.deleteProduct(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Producto eliminado"),
    ));
    _refreshProduct();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingProduct =
          _allProduct.firstWhere((element) => element['id'] == id);
      _nombreProductEditingController.text = existingProduct['nombre_product'];
      _precioEditingController.text = existingProduct['precio'].toString();
      _cantEditingController.text =
          existingProduct['cantidad_producto'].toString();
      _imagenEditingController.text = existingProduct['imagen'];
    } else {
      _nombreProductEditingController.text = "";
      _precioEditingController.text = "";
      _cantEditingController.text = "";
      _imagenEditingController.text = "";
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
              controller: _nombreProductEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombre del Producto",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _precioEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Precio",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cantEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Cantidad",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _imagenEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Imagen",
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addProduct();
                  } else {
                    await _updateProduct(id);
                  }
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Producto" : "Actualizar",
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
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Número de columnas
                            crossAxisSpacing:
                                10, // Espacio horizontal entre columnas
                            mainAxisSpacing: 10, // Espacio vertical entre filas
                            childAspectRatio:
                                0.75, // Ajusta este valor para controlar el tamaño de los elementos
                          ),
                          itemCount: _allProduct.length,
                          itemBuilder: (context, index) => Card(
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Mostrar la imagen del producto
                                Expanded(
                                  child: _allProduct[index]['imagen'] != null &&
                                          _allProduct[index]['imagen']
                                              .isNotEmpty
                                      ? Image.network(
                                          _allProduct[index]['imagen'],
                                          width: double.infinity,
                                          fit: BoxFit
                                              .cover, // Hace que la imagen cubra todo el espacio disponible
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                                child: Text(
                                                    'No se pudo cargar la imagen'));
                                          },
                                        )
                                      : Center(
                                          child:
                                              Text("No hay imagen disponible")),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _allProduct[index]['nombre_product'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    "\$${_allProduct[index]['precio'].toString()}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    "Cantidad: ${_allProduct[index]['cantidad_producto'].toString()}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          muestraDatos(
                                              _allProduct[index]['id']);
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.indigo,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _deleteProduct(
                                              _allProduct[index]['id']);
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: FloatingActionButton(
                onPressed: () => muestraDatos(null),
                child: Icon(Icons.add),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
