import 'package:flutter/material.dart';
import 'package:stone_war/games/match_games.dart';
import 'package:stone_war/games/yuk_mok/yuk_mok_solo_play.dart';

class YukMokMenu extends StatelessWidget {
  const YukMokMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '육목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => YukMokSoloPlay()),
            );
          },
          child: Text(
            '혼자 하기',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchGames(type: 3),
              ),
            );
          },
          child: Text(
            '같이 하기',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
