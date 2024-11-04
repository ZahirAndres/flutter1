import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user_app(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      usuario TEXT NOT NULL,
      cont TEXT NOT NULL,
      correo TEXT NOT NULL,
      nombre TEXT NOT NULL,
      rol INTEGER NOT NULL,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE producto_app(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      nombre_product TEXT NOT NULL,
      precio DOUBLE NOT NULL,
      cantidad_producto INTEGER NOT NULL,
      imagen TEXT NOT NULL,
      createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    /* await database.execute("""CREATE TABLE rol_permiso (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      userId INTEGER NOT NULL,
      rol TEXTN NOT NULL,
      FOREIGN KEY (userId) REFERENCES user_app (id)
    )"""); */

    // Crea administrador
    await database.execute("""INSERT INTO user_app(
      usuario, cont, correo, nombre, rol) values ('MrMexico2014','Linux2024!','rodriguez.mora.zahir.15@gmail.com','Zahir Andrés Rodríguez Mora',1)""");
  }

  // Crear base de datos
  static Future<sql.Database> db() async {
    return sql.openDatabase("database_product.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  // Crear un usuario
  static Future<int> createUser(String usuario, String cont, String nombre,
      String correo, int rol) async {
    final db = await SQLHelper.db();
    final user_app = {
      'usuario': usuario,
      'cont': cont,
      'nombre': nombre,
      'correo': correo,
      'rol': rol
    };
    final id = await db.insert('user_app', user_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Obtener todos los usuarios
  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user_app', orderBy: 'id');
  }

  // Obtener un solo usuario
  static Future<List<Map<String, dynamic>>> getSingleUser(String nomUsuario, String pass) async {
    final db = await SQLHelper.db();
    return db.query('user_app', where: "usuario=? AND cont=?", whereArgs: [nomUsuario, pass], limit: 1);
  }

  // Actualizar los usuarios
  static Future<int> updateUser(int id, String usuario, String cont,
      String nombre, String correo, int rol) async {
    final db = await SQLHelper.db();
    final user = {
      'usuario': usuario,
      'cont': cont,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'createdAT': DateTime.now().toString()
    };

    final result =
        await db.update('user_app', user, where: "id=?", whereArgs: [id]);
    return result;
  }

  // Borrar usuarios
  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    await db.delete('user_app', where: "id=?", whereArgs: [id]);
  }

  //Metodo para validar login de usuario
  static Future<bool> loginUser(String nombre, String pass, int rol) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'usuario = ? AND cont = ? AND rol = ?',
        whereArgs: [nombre, pass, rol]);

    if (user.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  /* Métodos para productos */

  //Agregar productos

  static Future<int> createProduct(String nombre_product, double precio, int cantidad_producto,
      String imagen) async {
    final db = await SQLHelper.db();
    final producto_app = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
    };
    final id = await db.insert('producto_app', producto_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<void> agregar(String nombreProduct, double precio, int cantidad, String categoria)async {
    final db = await SQLHelper.db();
    final product_app = {
      'nombProduct' : nombreProduct,
      'precio' : precio,
      'cantidad' : cantidad,
      'categoria' : categoria,
    };
    final id = await db.insert('product_app', product_app,
    conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print(id);
  }
  //Actualizar productos

  static Future<int> updateProduct(int id, String nombre_product, double precio,
      int cantidad_producto, String imagen) async {
    final db = await SQLHelper.db();
    final user = {
      'nombre_product': nombre_product,
      'precio': precio,
      'cantidad_producto': cantidad_producto,
      'imagen': imagen,
      'createdAT': DateTime.now().toString()
    };

    final result =
        await db.update('producto_app', user, where: "id=?", whereArgs: [id]);
    return result;
  }

  //Eliminar prodcutos

  static Future<void> deleteProduct(int id) async {
    final db = await SQLHelper.db();
    await db.delete('producto_app', where: "id=?", whereArgs: [id]);
  }

  //Mostrar productos

  static Future<List<Map<String, dynamic>>> getAllProduct() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }
}
