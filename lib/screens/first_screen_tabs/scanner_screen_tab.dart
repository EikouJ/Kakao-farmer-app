import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import "package:http/http.dart" as http;
import 'package:kakao_farmer/glob.dart';

class ScannerScreenTab extends StatefulWidget {
  const ScannerScreenTab({super.key});

  @override
  _ScannerScreenTabState createState() => _ScannerScreenTabState();
}

class _ScannerScreenTabState extends State<ScannerScreenTab> {
  // Import global main route for api
  final String apiHead = Glob.apiHead;

  late CameraController _controller = CameraController(
    CameraDescription(
      name: 'default',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    ),
    ResolutionPreset.max,
  );

  late Future<void> _initializeControllerFuture = _controller.initialize();

  /*late CameraController _controller;

  late Future<void> _initializeControllerFuture;*/

  /*@override
  void initState() {
    super.initState();
    _initializeCamera();
  }*/
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controller.value.isInitialized) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.max, // Set to the highest resolution available
    );

    _initializeControllerFuture = _controller.initialize();

    //await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    if (mounted) {
      setState(() {});
    }
  }

  Future<Map<String, dynamic>> _sendImageToApi(String imagePath) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$apiHead/models/predict/'));
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = json.decode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image chargée avec succès')),
        );
        return responseData;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger l\'image')),
        );

        throw Exception(
            "Impossible de charger l'image : ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image')),
      );

      throw Exception("Erreur pendant l'envoie de l'image : $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Transform.rotate(
                  angle: 90 * 3.1415927 / 180, // Rotate 90 degrees
                  child: Transform.scale(
                    scale: 1 * _controller.value.aspectRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ),
                  )),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Image capturée: ${image.path}')),
            );

            _sendImageToApi(image.path).then((responseData) {
              final predictedClass = responseData["predicted_class"];
              final description = responseData["desccription"];
              final causes = responseData["causes"];

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Résultats analyse'),
                    content: Column(
                      children: [
                        Text(
                          predictedClass,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          description,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          causes,
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Terminer'),
                      )
                    ],
                  );
                },
              );
            });
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
