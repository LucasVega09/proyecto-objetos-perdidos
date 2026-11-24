import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos/pages/detalle_objeto.dart';
import 'package:objetos/services/firestore_service.dart';

class ListaObjetos extends StatelessWidget {
  final bool misPubli;

  const ListaObjetos({super.key, required this.misPubli});

  @override
  Widget build(BuildContext context) {
    String? uid;

    if (misPubli) {
      uid = FirebaseAuth.instance.currentUser!.uid;
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().obtenerObjetos(autorUid: uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("no hay publicaciones"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final bool esAutor =
                doc["autorUid"] == FirebaseAuth.instance.currentUser!.uid;

            final bool devuelto = doc['estado'] == 'Devuelto';

            final tile = Container(
              color: devuelto ? Colors.grey.shade300 : Colors.white,
              child: ListTile(
                leading: Image.memory(
                  doc["foto"].bytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
                title: Text(doc["titulo"]),
                subtitle: Text(
                  '${doc['tipo']} - ${doc['categoria']} - ${doc['estado']}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleObjeto(doc: doc),
                    ),
                  );
                },

                trailing: devuelto
                    ? Text(
                        "Devuelto",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : SizedBox(),
              ),
            );

            if (!esAutor) return tile;

            return Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.endToStart,
              background: Container(color: Colors.red),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Borrar publicacion"),
                    content: Text(
                      'Seguro que desea borrar "${doc['titulo']}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("borrar"),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direccion) {
                FirestoreService().eliminarObjeto(doc.id);
              },
              child: tile,
            );
          },
        );
      },
    );
  }
}
