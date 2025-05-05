import 'package:flutter/material.dart';
import 'package:stone_war/menus/game_menus/dol_mok_menu.dart';
import 'package:stone_war/menus/game_menus/o_mok_menu.dart';
import 'package:stone_war/menus/game_menus/sa_mok_menu.dart';
import 'package:stone_war/menus/game_menus/yuk_mok_menu.dart';

class GameMenu extends StatelessWidget {
  const GameMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SaMokMenu(),
            OMokMenu(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DolMokMenu(),
            YukMokMenu(),
          ],
        ),
      ],
    );
  }
}
