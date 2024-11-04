import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aplicacion2/db_helper.dart';
import 'package:aplicacion2/main.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:aplicacion2/MailHelper.dart';

class ProductUsuario extends StatefulWidget {
  @override
  State<ProductUsuario> createState() => _ProductState();
}

class _ProductState extends State<ProductUsuario> {
  List<Map<String, dynamic>> _allProduct = [];
  List<Map<String, dynamic>> _cart = [];
  bool _isLoading = true;
  Timer? _inactividadTimer;

  void _refreshProduct() async {
    final product = await SQLHelper.getAllProduct();
    setState(() {
      _allProduct = product;
      _isLoading = false;
    });
  }

  void cerrarSesion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

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

  void _showQuantityDialog(Map<String, dynamic> product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar cantidad'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() => quantity--);
                  }
                },
              ),
              Text(quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  if (quantity < product['cantidad_producto']) {
                    setState(() => quantity++);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _addToCart({...product, 'cart_quantity': quantity});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Producto añadido al carrito')),
              );
            },
            child: Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      int existingIndex = _cart.indexWhere(
        (item) => item['id'] == product['id'],
      );

      if (existingIndex != -1) {
        int newQuantity =
            _cart[existingIndex]['cart_quantity'] + product['cart_quantity'];
        if (newQuantity <= product['cantidad_producto']) {
          _cart[existingIndex]['cart_quantity'] = newQuantity;
        }
      } else {
        _cart.add(product);
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _updateCartQuantity(
      int index, int newQuantity, StateSetter bottomSheetSetState) {
    if (newQuantity > 0 && newQuantity <= _cart[index]['cantidad_producto']) {
      setState(() {
        _cart[index]['cart_quantity'] = newQuantity;
      });
      bottomSheetSetState(() {});
    }
  }

  Future<void> _sendMail(Map<String, dynamic> product) async {
    await MailHelper.send(
      product['nombre_product'],
      product['precio'],
      product['cart_quantity'],
      product['imagen'],
    );
    int newQuantity = product['cantidad_producto'] - product['cart_quantity'];
    await SQLHelper.updateProduct(
      product['id'],
      product['nombre_product'],
      product['precio'].toDouble(),
      newQuantity,
      product['imagen'],
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido enviado correctamente'),
        backgroundColor: Colors.green,
      ),
    );

    _refreshProduct();
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, bottomSheetSetState) => Column(
            children: [
              ListTile(
                title: Text('Carrito de Compras'),
                trailing: SizedBox(
                  width: 96,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                      
                          // Muestra un indicador de carga
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(child: CircularProgressIndicator());
                            },
                          );

                          // Procesa el envío de los correos
                          for (var product in _cart) {
                            await _sendMail(product);
                          }
                          setState(() {
                            _cart.clear();
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductUsuario()),
                          );

                          // Muestra un mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Todos los pedidos fueron procesados correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_sweep),
                        onPressed: () {
                          setState(() {
                            _cart.clear();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Resto de la UI del carrito permanece igual
              Expanded(
                child: ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: _cart[index]['imagen'] != null &&
                                          _cart[index]['imagen'].isNotEmpty
                                      ? Image.network(
                                          _cart[index]['imagen'],
                                          fit: BoxFit.cover,
                                        )
                                      : Center(child: Text("No hay imagen")),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _cart[index]['nombre_product'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "\$${_cart[index]['precio'].toString()}",
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () => _updateCartQuantity(
                                    index,
                                    _cart[index]['cart_quantity'] - 1,
                                    bottomSheetSetState,
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    _cart[index]['cart_quantity'].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () => _updateCartQuantity(
                                    index,
                                    _cart[index]['cart_quantity'] + 1,
                                    bottomSheetSetState,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _removeFromCart(index);
                                    });
                                    bottomSheetSetState(() {});
                                    if (_cart.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Text(
                  'Total: \$${_cart.fold(0.0, (sum, item) => sum + (item['precio'] * item['cart_quantity'])).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Rest of the build method and other methods remain exactly the same
  @override
  Widget build(BuildContext context) {
    // Your existing build method remains unchanged
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
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: _showCart,
                    ),
                    if (_cart.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            _cart.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
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
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _allProduct.length,
                          itemBuilder: (context, index) => Card(
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _allProduct[index]['imagen'] != null &&
                                          _allProduct[index]['imagen']
                                              .isNotEmpty
                                      ? Image.network(
                                          _allProduct[index]['imagen'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
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
                                    "Disponible: ${_allProduct[index]['cantidad_producto'].toString()}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _showQuantityDialog(_allProduct[index]),
                                    child: Text('Añadir al carrito'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
