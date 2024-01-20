import 'package:flutter/material.dart';
import 'package:pic_answer/pick_answer.dart';
import 'package:flutter/services.dart';


var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 73,86,105),
  brightness: Brightness.dark, //This tells flutter that this color scheme is for dark mode
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
  runApp(MaterialApp(
    theme: ThemeData.dark().copyWith(
      colorScheme: kColorScheme,
      cardTheme: const CardTheme().copyWith(
        color: kColorScheme.secondaryContainer,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kColorScheme.primaryContainer,
        ),
      ),
      textTheme: ThemeData().textTheme.copyWith( //we use this to override selected parts that you say.
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: kColorScheme.onSecondaryContainer, fontSize: 16), //it only changes the appbar cuz title large only applies to app bar
      ),
    ),
    home: const ToText(),
    themeMode: ThemeMode.dark,
    )
  );
  });
}
