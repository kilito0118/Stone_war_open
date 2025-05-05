import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

final random = Random();
const List<String> game = [
  "deduplicated_dol_mok.txt",
  'deduplicated_sa_mok.txt',
  'deduplicated_yuk_mok.txt',
  'deduplicated_o_mok.txt',
  'deduplicated_stone_war.txt',
];

class RandomGenerate extends StatefulWidget {
  final TextEditingController controller;
  const RandomGenerate({
    super.key,
    required this.controller,
  });

  @override
  RandomGenerateState createState() => RandomGenerateState();
}

class RandomGenerateState extends State<RandomGenerate> {
  Future<String> readFile(String filename) async {
    try {
      if (!kIsWeb) {
        return await rootBundle
            .loadString('assets/nickname_generate_words/$filename');
      }
      return await rootBundle.loadString('nickname_generate_words/$filename');
    } catch (e) {
      return '에러{$e}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        String result = "";
        String preposition = await readFile("deduplicated_preposition.txt");
        String title = await readFile(game[random.nextInt(5)]);
        String name = await readFile("deduplicated_names.txt");
        List<String> prepositions = preposition.split('\n');
        List<String> titles = title.split('\n');
        List<String> names = name.split('\n');

        final buffer = StringBuffer()
          ..write(prepositions[random.nextInt(prepositions.length)])
          ..write(titles[random.nextInt(titles.length)])
          ..write(names[random.nextInt(names.length)]);
        result = buffer.toString().replaceAll(RegExp(r'\s+'), '');

        setState(() {
          widget.controller.value = TextEditingValue(
            text: result,
            selection: TextSelection.fromPosition(
              TextPosition(offset: result.length),
            ),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
          //widget.controller.text = result;
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            if (states.contains(WidgetState.hovered)) {
              return Colors.blue[200]!;
            }
            return Colors.transparent; // 기본
          },
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '🎲',
              style: TextStyle(
                fontFamily: 'NotoEmoji', // 이모지를 지원하는 폰트를 지정
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: '무작위 생성',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            TextSpan(
              text: '🎲',
              style: TextStyle(
                fontFamily: 'NotoEmoji', // 이모지를 지원하는 폰트를 지정
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
