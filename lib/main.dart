import 'package:flutter/material.dart';
import 'package:pic_answer/pick_answer.dart';
import 'package:flutter/services.dart';

var kColorScheme = ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 96, 59, 181));

var kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 5, 99, 125),
  brightness: Brightness.dark, //This tells flutter that this color scheme is for dark mode
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
  runApp(MaterialApp(
     darkTheme: ThemeData.dark().copyWith(
      colorScheme: kDarkColorScheme,
      cardTheme: const CardTheme().copyWith(
        color: kDarkColorScheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
      ),  
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkColorScheme.primaryContainer,
          foregroundColor: kDarkColorScheme.onPrimaryContainer,
        ),
      ),
    ),
    theme: ThemeData.dark().copyWith(
      colorScheme: kColorScheme,
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: kColorScheme.onPrimaryContainer,
        foregroundColor: kColorScheme.primaryContainer
      ),  
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
    themeMode: ThemeMode.light,
    )
  );
  });
}
