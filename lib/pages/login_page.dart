import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:objetos/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String mensajeError = "";
  bool hayError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30),
          width: 300,
          height: 300,
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Inicie sesion con su cuenta de Google',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      hayError = false;
                      await AuthService().iniciarSesionGoogle();
                    } catch (ex) {
                      hayError = true;
                      setState(() {});
                    }
                  },
                  child: Text("Iniciar sesion"),
                ),
              ),

              SizedBox(height: 25),

              hayError
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.red.shade100),
                      child: Row(
                        children: [
                          Icon(MdiIcons.alertCircle, color: Colors.red),
                          SizedBox(width: 10),
                          Text("No se pudo iniciar sesion"),
                        ],
                      ),
                    )
                  : SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
