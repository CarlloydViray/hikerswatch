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
      theme: ThemeData(fontFamily: GoogleFonts.merriweather().fontFamily),
      home: const homePageScreen(),
    );
  }
}
