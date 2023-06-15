import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/main.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imgdart;
import 'package:path_provider/path_provider.dart';

// import 'package:image_editor/image_editor.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = ModalRoute.of(context)?.settings.arguments as User?;
    return const DrawingBoard();
  }
}

class DrawingBoard extends StatefulWidget {
  const DrawingBoard({
    Key? key,
  }) : super(key: key);
  // const DrawingBoard({super.key});

  @override
  State<DrawingBoard> createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  ui.PictureRecorder recorder = ui.PictureRecorder();

  Color selectedColor = Colors.black;
  double strokeWidth = 5;
  List<DrawingPoint?> drawingPoints = [];
  List<Color> colors = [
    Colors.pink,
    Colors.red,
    Colors.black,
    Colors.yellow,
    Colors.lightBlue,
    Colors.purple,
    Colors.green,
  ];

  ui.Image? img;
  _DrawingPainter? myPainter;

  Future<void> _getImage() async {
    // Pick an image from the gallery
    ImagePicker picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);

    // If the user picked an image, set the image variable
    if (image != null) {
      //setState(() async {
      File _image = File(image.path);
      // Read the bytes from the file.
      Uint8List bytes = await _image.readAsBytes();

      ui.Codec codec = await ui.instantiateImageCodec(bytes);

      // Retrieve the first frame from the codec
      ui.FrameInfo frameInfo = await codec.getNextFrame();

      // Convert the frame to a ui.Image
      img = frameInfo.image;
      setState(() {});
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanUpdate: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPanEnd: (details) {
              setState(() {
                drawingPoints.add(null);
              });
            },
            child: CustomPaint(
              painter: myPainter =
                  _DrawingPainter(drawingPoints, img, recorder),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: Row(
              children: [
                Slider(
                  min: 0,
                  max: 40,
                  value: strokeWidth,
                  onChanged: (val) => setState(() => strokeWidth = val),
                ),
                ElevatedButton.icon(
                  onPressed: () => setState(() => drawingPoints = []),
                  icon: Icon(Icons.clear),
                  label: Text("Clear Board"),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          color: Colors.red[200],
          padding: EdgeInsets.all(10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    colors.length,
                    (index) => _buildColorChose(colors[index]),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HomePage(),
                      ElevatedButton(
                        child: const Text("Gallery"),
                        onPressed: () {
                          // Return the value of the image file.
                          _getImage();
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Save Pics"),
                        onPressed: () {
                          // Return the value of the image file.
                          saveImage();
                        },
                      )
                    ])
              ]),
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildColorChose(Color color) {
    bool isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        height: isSelected ? 47 : 40,
        width: isSelected ? 47 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }

  Future<void> saveImage() async {
    // Create a PictureRecorder.
    final recorder = ui.PictureRecorder();

    // Create a Canvas and attach it to the PictureRecorder.
    final canvas = Canvas(recorder);

    // Paint the CustomPainter on the Canvas.
    Size size = Size(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    myPainter!.paint(canvas, size);

    // Create an Image from the PictureRecorder.
    final image = await recorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Directory? dir = await getExternalStorageDirectory();
    String path = '/storage/emulated/0/Download/my_image.png';
    // Save the Image to a file.
    // if (!File(path).existsSync()) {
    //   throw ArgumentError('The path is not a valid file path.');
    // }
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Save the PNG image to the file.
    await File(path).writeAsBytes(pngBytes);
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final ui.Image? img;
  final ui.PictureRecorder recorder;

  _DrawingPainter(this.drawingPoints, this.img, this.recorder) {
    // myCanvas = Canvas(recorder);
  }

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas myCanvas = Canvas(recorder);
    if (img != null) {
      canvas.drawImage(img!, Offset.zero, Paint());
      // myCanvas.drawImage(img!, Offset.zero, Paint());
    }
    for (int i = 0; i < drawingPoints.length; i++) {
      if (drawingPoints[i] != null && drawingPoints[i + 1] != null) {
        canvas.drawLine(drawingPoints[i]!.offset, drawingPoints[i + 1]!.offset,
            drawingPoints[i]!.paint);
        // myCanvas.drawLine(drawingPoints[i]!.offset, drawingPoints[i + 1]!.offset,
        // drawingPoints[i]!.paint);
      } else if (drawingPoints[i] != null && drawingPoints[i + 1] == null) {
        offsetsList.clear();
        offsetsList.add(drawingPoints[i]!.offset);

        canvas.drawPoints(
            ui.PointMode.points, offsetsList, drawingPoints[i]!.paint);
        // myCanvas.drawPoints(
        //     ui.PointMode.points, offsetsList, drawingPoints[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const MyApp()));
        },
        child: const Text('HOME'));
  }
}

class Gallery extends StatelessWidget {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _image = File(pickedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ImageEditorExample()));
          _pickImage();
          // final pickedImage = await Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => MyHomePage()),
          // );
        },
        child: const Text('GALERİ'));
  }
}

class SavedPicks extends StatelessWidget {
  const SavedPicks({super.key});
  List<String> getSavedWorks() {
    // veritabanından kaydedilen çalışmaları almak için burada gerekli kodu yazın
    // örneğin, bir SQL sorgusu kullanabilirsiniz
    List<String> savedWorks = getSavedWorks();
    List<Widget> workButtons = [];
    for (String work in savedWorks) {
      workButtons.add(
        ElevatedButton(
          onPressed: () {
            // çalışmayı açmak için burada gerekli kodu yazın
          },
          child: Text(work),
        ),
      );
    }
    return ['Çalışma 1', 'Çalışma 2', 'Çalışma 3'];
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => SavedPics()));
          Navigator.pushNamed(context, '/');
        },
        child: const Text('resim'));
  }
}


