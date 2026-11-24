import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  Future<List<String>> obtenerCategorias() async {
    final consulta = await FirebaseFirestore.instance
        .collection("categorias")
        .get();

    List<String> categorias = [];

    for (var doc in consulta.docs) {
      categorias.add(doc["nombre"]);
    }
    return categorias;
  }

  Future<void> guardarObjeto(Map<String, dynamic> datos) async {
    await FirebaseFirestore.instance.collection("objetos").add(datos);
  }

  Stream<QuerySnapshot> obtenerObjetos({String? autorUid}) {
    Query consulta = FirebaseFirestore.instance.collection("objetos");

    if (autorUid != null) {
      consulta = consulta.where("autorUid", isEqualTo: autorUid);
    }

    return consulta.snapshots();
  }

  Future<void> marcarDevuelto(String id) async {
    await FirebaseFirestore.instance.collection("objetos").doc(id).update({
      'estado': 'Devuelto',
    });
  }

  Future<void> eliminarObjeto(String id) async {
    await FirebaseFirestore.instance.collection("objetos").doc(id).delete();
  }
}
