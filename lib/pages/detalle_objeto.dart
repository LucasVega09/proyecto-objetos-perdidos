import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:objetos/services/firestore_service.dart';

class DetalleObjeto extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const DetalleObjeto({super.key, required this.doc});

  String dosDigitos(int n) {
    return n.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final f = doc['fecha'].toDate();
    final fechaTexto =
        '${dosDigitos(f.day)}/${dosDigitos(f.month)}/${f.year} ${dosDigitos(f.hour)}:${dosDigitos(f.minute)}';

    final bool esAutor =
        doc["autorUid"] == FirebaseAuth.instance.currentUser!.uid;

    final bool vigente = doc["estado"] == "Vigente";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade50,
        title: Text('Detalle'),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(
              doc["foto"].bytes,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doc["titulo"]),
                  SizedBox(height: 10),
                  Text('Descripcion: ${doc['descripcion']}'),
                  SizedBox(height: 10),
                  Text('Tipo: ${doc['tipo']}'),
                  SizedBox(height: 10),
                  Text('Categoria: ${doc['categoria']}'),
                  SizedBox(height: 10),
                  Text('Lugar: ${doc['lugar']}'),
                  SizedBox(height: 10),
                  Text('Fecha: $fechaTexto'),
                  SizedBox(height: 10),
                  Text('Estado: ${doc['estado']}'),
                  SizedBox(height: 10),
                  Text('Publicado por: ${doc['autorNombre']}'),

                  SizedBox(height: 20),

                  esAutor && vigente
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirestoreService().marcarDevuelto(doc.id);
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            },
                            child: Text("marcar como devuelto"),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
