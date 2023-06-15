

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:locator/locator.dart';
import 'firebase_options.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';

import 'secondScreen.dart';
//import 'auth_service.dart';
//import 'package:get_it/get_it.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yıldızSlider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<String> listImages = [
    'assets/images/photo1.jpg',
    'assets/images/photo2.jpg',
    'assets/images/photo3.jpg',
    'assets/images/photo4.jpg',
    'assets/images/photo5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(
            height: 10,
            width: 10,
          ),
          FanCarouselImageSlider(
            imagesLink: [
              'assets/images/photo1.jpg',
              'assets/images/photo2.jpg',
              'assets/images/photo3.jpg',
              'assets/images/photo4.jpg',
              'assets/images/photo5.jpg',
            ],
            isAssets: true,
            autoPlay: true,
          ),
          const MyButton()
        ]),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context,
             MaterialPageRoute(builder: (context) => const SecondScreen()));
        },
        child: const Text('giriş yapmadandevam et'));
  }
}

Widget logos() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/googlelogo.jpg'),
        const SizedBox(width: 24),
        InkWell(
            onTap: () async {
             // Locator.get <AuthService>().signInWithGoogle().then((value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SecondScreen(), settings: RouteSettings(arguments: value))));
            },
            child: Image.asset('assets/images/google.png')),
      ],
    ),
  );
}
