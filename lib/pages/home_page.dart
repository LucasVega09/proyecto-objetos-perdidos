import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:objetos/pages/lista_objetos.dart';
import 'package:objetos/pages/nuevo_objeto.dart';
import 'package:objetos/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user;

  @override
  void initState() {
    super.initState();
    AuthService().currentUser().then((usuarioActual) {
      if (!mounted) return;
      setState(() {
        user = usuarioActual;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amberAccent,
          title: Text(user?.displayName ?? "Cargando datos..."),
          actions: [
            PopupMenuButton(
              onSelected: (valor) => AuthService().cerrarSesion(),
              icon: Icon(MdiIcons.logout),
              iconColor: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem(value: "logout", child: Text('Cerrar sesion')),
              ],
            ),
          ],

          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Mis publicaciones"),
              Tab(text: "Ver objetos"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            ListaObjetos(misPubli: true),
            ListaObjetos(misPubli: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue.shade400,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NuevoObjeto()),
            );
          },
          child: Icon(MdiIcons.plus, color: Colors.white),
        ),
      ),
    );
  }
}
