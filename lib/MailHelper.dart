// ignore: file_names
// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHelper {
  static Future<void> send(String ?nombProduct, double ?precio, int ?cantidad,String ?imgProduct) async {
// Asegúrate de que la autenticación de dos factores esté habilitada y de crear una contraseña de aplicación.
    String username = 'gds0641.tsu.iv@gmail.com';
    String password = 'ndbl iiub ivzd qvng';
    String destino = 'gds0641.tsu.iv@gmail.com'; 
    final smtpServer = gmail(username, password);

// Crear nuestro mensaje.
    final message = Message()
  ..from = Address(username, 'Zahir Andrés Rodriguez Mora')
  ..recipients.add(destino)
  ..ccRecipients.addAll([username, destino])
  ..bccRecipients.add(Address(destino))
  ..subject = 'El producto enviado fue $nombProduct Fecha: ${DateTime.now()}'
  ..text = 'Esto es un texto plano.'
  ..html = """
    <!DOCTYPE html>
    <html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Pedido $username</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f4f4f4;
            }
            .container {
                width: 80%;
                margin: 20px auto;
                background-color: #fff;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                padding: 20px;
            }
            .header {
                text-align: center;
                padding-bottom: 20px;
                border-bottom: 1px solid #ddd;
            }
            .header img {
                width: 150px;
                margin-bottom: 10px;
            }
            .header h1 {
                font-size: 24px;
                margin: 0;
                color: #333;
            }
            .content {
                padding: 20px 0;
            }
            .content h2 {
                font-size: 20px;
                margin-bottom: 10px;
                color: #333;
            }
            .content p {
                font-size: 16px;
                margin: 5px 0;
                color: #555;
            }
            .product-img {
                width: 100%;
                max-width: 300px;
                margin: 10px auto;
                display: block;
            }
            .footer {
                text-align: center;
                padding: 10px 0;
                border-top: 1px solid #ddd;
                margin-top: 20px;
            }
            .footer p {
                font-size: 14px;
                color: #777;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <img src="URL_DEL_LOGO" alt="Logo Ejemplo">
                <h1>Pedido de $username</h1>
            </div>
            <div class="content">
                <h2>Detalles del Producto</h2>
                <p><strong>Nombre del Producto:</strong> $nombProduct</p>
                <p><strong>Cantidad:</strong> $cantidad</p>
                <p><strong>Precio:</strong> $precio</p>
                <img src="$imgProduct" alt="Imagen del Producto" class="product-img">
            </div>
            <div class="footer">
                <p>Gracias por su compra en Ejemplo. ¡Esperamos verte pronto!</p>
            </div>
        </div>
    </body>
    </html>
  """;


// Crear un mensaje equivalente.
    /* final equivalentMessage = Message()
      ..from = Address(
          username, 'Zahir Andrés Rodríguez mora') // Cambia 'Your Name' por el nombre que desees
      ..recipients.add(Address(username))
      ..ccRecipients.addAll([Address(destino), destino])
      ..bccRecipients.add('bccAddress@example.com') //Enviar un comprobante
      ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html =
          '<h1>Test</h1>\n<p>Hey! Here is some HTML content</p><img src="cid:myimg@3.141"/>'
      ..attachments = [
        FileAttachment(File(''))
          ..location = Location.inline
          ..cid = '<myimg@3.141>'
      ];
 */
// Crear una conexión persistente
    var connection = PersistentConnection(smtpServer);

// Enviar el primer mensaje
    await connection.send(message);

// Enviar el mensaje equivalente
    /* await connection.send(equivalentMessage);
 */
// Cerrar la conexión
    await connection.close();
  }
}
