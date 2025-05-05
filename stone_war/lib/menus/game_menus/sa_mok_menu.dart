import 'package:flutter/material.dart';
import 'package:stone_war/games/match_games.dart';
import 'package:stone_war/games/sa_mok/sa_mok_solo_play.dart';

class SaMokMenu extends StatelessWidget {
  const SaMokMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '사목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SaMokSoloPlay()),
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
                builder: (context) => MatchGames(type: 1),
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
