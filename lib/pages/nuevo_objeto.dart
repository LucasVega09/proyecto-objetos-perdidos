import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objetos/services/auth_service.dart';
import 'package:objetos/services/firestore_service.dart';

class NuevoObjeto extends StatefulWidget {
  const NuevoObjeto({super.key});

  @override
  State<NuevoObjeto> createState() => _NuevoObjetoState();
}

class _NuevoObjetoState extends State<NuevoObjeto> {
  List<String> categorias = [];
  String? categoriaElegida;
  String? tipoElegido;

  //datos para la fecha
  DateTime? fechaElegida;
  bool errorFecha = false;

  //datos para el formulario del + de abajo
  final formKey = GlobalKey<FormState>();
  final tituloCtrl = TextEditingController();
  final descripcionCtrl = TextEditingController();
  final lugarCtrl = TextEditingController();

  //cosas para la foto
  Uint8List? fotoBytes;
  String errorFoto = "";

  @override
  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
    lugarCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    FirestoreService().obtenerCategorias().then((lista) {
      if (!mounted) return;
      setState(() {
        categorias = lista;
      });
    });
  }

  //el void para la fecha
  void elegirFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (fecha == null) return;
    if (!mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    setState(() {
      fechaElegida = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
      errorFecha = false;
    });
  }

  String dosDigitos(int n) {
    return n.toString().padLeft(2, '0');
  }

  //foto
  void elegirFoto(ImageSource origen) async {
    final picker = ImagePicker();
    final archivo = await picker.pickImage(
      source: origen,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );

    if (archivo == null) return;

    final bytes = await archivo.readAsBytes();

    if (!mounted) return;

    if (bytes.length > 900000) {
      setState(() {
        fotoBytes = null;
        errorFoto = "la foto es muy pesada";
      });
      return;
    }

    setState(() {
      fotoBytes = bytes;
      errorFoto = "";
    });
  }

  void publicar() async {
    try {
      final usuario = await AuthService().currentUser();

      await FirestoreService().guardarObjeto({
        'titulo': tituloCtrl.text.trim(),
        'descripcion': descripcionCtrl.text.trim(),
        'lugar': lugarCtrl.text.trim(),
        'tipo': tipoElegido,
        'categoria': categoriaElegida,
        'fecha': Timestamp.fromDate(fechaElegida!),
        'foto': Blob(fotoBytes!),
        'estado': 'Vigente',
        'autorUid': usuario!.uid,
        'autorNombre': usuario.displayName,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (ex) {
      if (!mounted) return;
      setState(() {
        errorFoto = "no se pudo guardar la publicacion";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade400,
        title: Text('Agregar un nuevo objeto'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: tituloCtrl,
                decoration: InputDecoration(labelText: "Titulo"),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "ingrese un titulo";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              TextFormField(
                controller: descripcionCtrl,
                decoration: InputDecoration(labelText: "Descripcion"),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "ingrese una descripcion";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              TextFormField(
                controller: lugarCtrl,
                decoration: InputDecoration(labelText: "Lugar (EJ: Sala U200)"),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "ingrese el lugar";
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tipo'),
                items: [
                  DropdownMenuItem(value: 'Perdido', child: Text('Perdido')),
                  DropdownMenuItem(
                    value: 'Encontrado',
                    child: Text('Encontrado'),
                  ),
                ],
                onChanged: (valor) {
                  tipoElegido = valor;
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Seleccione una opcion';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoria'),
                items: categorias.map((nombre) {
                  return DropdownMenuItem(value: nombre, child: Text(nombre));
                }).toList(),
                onChanged: (valor) {
                  categoriaElegida = valor;
                },
                validator: (valor) {
                  if (valor == null) {
                    return 'Seleccione una categoria';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: elegirFechaHora,
                  child: Text(
                    fechaElegida == null
                        ? "elegir fecha y hora"
                        : '${dosDigitos(fechaElegida!.day)}/${dosDigitos(fechaElegida!.month)}/${fechaElegida!.year} ${dosDigitos(fechaElegida!.hour)}:${dosDigitos(fechaElegida!.minute)}',
                  ),
                ),
              ),

              errorFecha
                  ? Text(
                      'Seleccione fecha y hora',
                      style: TextStyle(color: Colors.red),
                    )
                  : SizedBox(),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => elegirFoto(ImageSource.camera),
                      child: Text('camara'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => elegirFoto(ImageSource.gallery),
                      child: Text('galeria'),
                    ),
                  ),
                ],
              ),

              fotoBytes == null
                  ? SizedBox()
                  : Image.memory(fotoBytes!, height: 200),

              errorFoto == ""
                  ? SizedBox()
                  : Text(errorFoto, style: TextStyle(color: Colors.red)),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    bool formularioOk = formKey.currentState!.validate();

                    if (fechaElegida == null) {
                      errorFecha = true;
                    }
                    if (fotoBytes == null && errorFoto == "") {
                      errorFoto = "error, seleccione una foto";
                    }
                    setState(() {});
                    if (formularioOk &&
                        fechaElegida != null &&
                        fotoBytes != null) {
                      publicar();
                    }
                  },
                  child: Text('publicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
