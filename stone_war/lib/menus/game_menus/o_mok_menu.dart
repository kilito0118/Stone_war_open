import 'package:flutter/material.dart';
import 'package:stone_war/games/match_games.dart';
import 'package:stone_war/games/o_mok/o_mok_solo_play.dart';

class OMokMenu extends StatelessWidget {
  const OMokMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '오목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OMokSoloPlay()),
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
                  builder: (context) => MatchGames(
                        type: 2,
                      )),
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
