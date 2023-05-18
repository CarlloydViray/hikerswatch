import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hikerswatch_viraycarlloyd/screens/homePageScreen.dart';

void main(List<String> args) {
  runApp(const MyMain());
}

class MyMain extends StatelessWidget {
  const MyMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.merriweather().fontFamily,
        appBarTheme: const AppBarTheme(color: Color(0XFF025464)),
      ),

      home: AnimatedSplashScreen(
          duration: 3000,
          splashTransition: SplashTransition.scaleTransition,
          splash: const Icon(
            Icons.cloud_circle_rounded,
            size: 100,
            color: Color(0XFF025464),
          ),
          nextScreen: const homePageScreen()),
      // home: const homePageScreen(),
    );
  }
}
