import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Se asegura que los plugins estén inicializados (necesario para ejecutar availableCameras)
  WidgetsFlutterBinding.ensureInitialized();

  // Obtiene la lista de cámaras disponibles
  List<CameraDescription> cameras = await availableCameras();

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePicture(cameras.first),
    ),
  );
}

class TakePicture extends StatefulWidget {
  TakePicture(this.camera);

  CameraDescription camera;

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> {
  late CameraController controller;
  late Future<void> isControllerReady;

  @override
  void initState() {
    super.initState();
    // El controlador de la cámara
    controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
    );
    // initialize() es asíncrona (devuelve un Future)
    isControllerReady = controller.initialize();
  }

  @override
  void dispose() {
    // libera la cámara antes de destruir la widget
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tome una foto...')),
      // Espera a que el controller se haya inicializado
      body: FutureBuilder<void>(
        future: isControllerReady,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Si el Future del controlador terminó, presenta el preview de la cámara
            return Center(
              child: Column(
                children: [
                  Expanded(
                    child: CameraPreview(controller),
                  ),
                  ElevatedButton(
                    child: Icon(Icons.camera),
                    onPressed: () async {
                      XFile image = await controller.takePicture();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowPicture(image.path)),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            // Caso contrario presenta un indicador de "trabajando"
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class ShowPicture extends StatelessWidget {
  ShowPicture(this.imgpath);

  final String imgpath;

  showSnapshot(context) {
    final snackBar = SnackBar(content: Text('En archivo: ${imgpath}'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Esta es su foto...')),
      body: Container(
        child: Image.file(File(imgpath), fit: BoxFit.cover),
        width: MediaQuery.of(context).size.width,
      ),
      bottomNavigationBar: BottomAppBar(child: Text('${imgpath}')),
    );
  }
}
