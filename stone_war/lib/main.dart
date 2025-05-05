import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_war/title_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fontLoader = FontLoader('힘찬체')
    ..addFont(rootBundle.load('assets/fonts/인천교육힘찬.ttf'));

  await fontLoader.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var baseStyle = TextStyle(fontFamily: '힘찬체', color: Colors.black);

    return MaterialApp(
      theme: ThemeData(
        fontFamily: '힘찬체',
        textTheme: TextTheme(
          displayLarge: baseStyle.copyWith(fontSize: 18),
          displayMedium: baseStyle.copyWith(fontSize: 13),
          bodyLarge: baseStyle.copyWith(fontSize: 38),
          bodyMedium: baseStyle.copyWith(fontSize: 28),
          bodySmall: baseStyle.copyWith(fontSize: 22),
          titleLarge: baseStyle.copyWith(fontSize: 76),
          titleMedium: baseStyle.copyWith(fontSize: 36),
        ),
      ),
      //home: TitleScreen(),
      //home: SignupPage(),
      home: TitleScreen(),
    );
  }
}
