import 'package:aplicacion2/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class Registro extends StatefulWidget {
  @override
  _RegistroState createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _usuarioEditingController = TextEditingController();
  final TextEditingController _contEditingController = TextEditingController();
  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _correoEditingController = TextEditingController();
  bool _isPasswordVisible = false;
  

  Future<void> _addUser() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      await SQLHelper.createUser(
        _usuarioEditingController.text,
        _contEditingController.text,
        _nombreEditingController.text,
        _correoEditingController.text,
        2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Usuario registrado con éxito"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Por favor, completa el formulario correctamente"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'usuario',
                controller: _usuarioEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Usuario",
                ),
                validator: FormBuilderValidators.required(),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'contrasena',
                controller: _contEditingController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6,
                      errorText: "La contraseña debe tener al menos 6 caracteres"),
                ]),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'nombres',
                controller: _nombreEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nombres",
                ),
                validator: FormBuilderValidators.required(),
              ),
              SizedBox(height: 10),
              FormBuilderTextField(
                name: 'correo',
                controller: _correoEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Correo",
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _addUser();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      "Registrar Usuario",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
