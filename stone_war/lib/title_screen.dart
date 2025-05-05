import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stone_war/home_screen.dart';
import 'package:stone_war/const/color.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:stone_war/login/login_page.dart';
import 'dart:math';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});
  @override
  State<StatefulWidget> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  //소리 재생 부분
  final AudioPlayer _audioPlayer = AudioPlayer();
  Random random = Random();
  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('audios/착수.mp3'));
  }

  final FlutterTts flutterTts = FlutterTts();

  void initializeTts() async {
    // 언어 설정 (한국어)
    await flutterTts.setLanguage("ko-KR");
    // 음성 톤 설정
    await flutterTts.setPitch(0.3);
    List<String> voices = [
      'ko-kr-x-kod-local',
      'ko-kr-x-kob-local',
      'ko-KR-language',
      'ko-kr-x-kod-network',
      'ko-kr-x-koc-network',
      'ko-kr-x-kob-network',
      'ko-kr-x-ism-local'
    ];
    await flutterTts.setVoice(
        {'name': voices[random.nextInt(voices.length)], 'locale': 'ko-KR'});
    flutterTts.setCompletionHandler(() async {
      // TTS가 끝났을 때 실행될 작업
      await _playSound(); // TTS 후 소리 재생
      await Future.delayed(Duration(milliseconds: 730));
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    user != null ? HomeScreen() : LoginPage()),
            (route) => false);
      }
    });
  }

  void speakTitle(String text) async {
    await flutterTts.speak(text); // TTS 음성 출력
  }

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: GestureDetector(
        onTap: () async {
          speakTitle("석전");
          //await Future.delayed(Duration(milliseconds: 500)); // 500ms 딜레이
          //_playSound();

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeScreen()),
          // );
        },
        child: Container(
          width: double.infinity, // 화면 전체 가로
          height: double.infinity, // 화면 전체 세로
          color: Colors.transparent, // 투명하게 설정 (터치 감지 가능)
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '석전',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '시작하려면 누르세요.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
