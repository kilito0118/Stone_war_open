import 'package:flutter/material.dart';
import 'package:stone_war/games/dol_mok/dol_mok_solo_play.dart';

class DolMokMenu extends StatelessWidget {
  const DolMokMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '돌목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DolMokSoloPlay()),
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
              MaterialPageRoute(builder: (context) => DolMokSoloPlay()),
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
