import 'package:flutter/material.dart';
export 'package:stone_war/games/check/game_o_mok.dart';
export 'package:flutter/foundation.dart';
export 'package:stone_war/games/game_components/about_game.dart';
export 'package:audioplayers/audioplayers.dart';
export 'package:stone_war/const/color.dart';

export 'package:stone_war/games/game_components/players_profile.dart';

class OBoardPainter extends CustomPainter {
  final List<List<int>> board;

  OBoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    double cellSize = size.width / board.length;

    // 바둑판 그리기
    for (int i = 0; i < board.length; i++) {
      double offset = i * cellSize + 20; // 바둑판이면 20을 더하기
      canvas.drawLine(Offset(20, offset), Offset(size.width - 20, offset),
          linePaint); // 가로선
      canvas.drawLine(Offset(offset, 20), Offset(offset, size.height - 20),
          linePaint); // 세로선
      if (i == 7) {
        canvas.drawCircle(Offset(offset, offset), cellSize * 0.2, linePaint);
      }
    }

    // 돌 그리기
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] != 0) {
          Paint stonePaint = Paint()
            ..color = board[row][col] == 1
                ? Colors.black
                : board[row][col] == 2
                    ? Colors.white
                    : Colors.green;
          if (board[row][col] == -1) {
            board[row][col] = 0;
          }
          double centerX = (col + 0.5) * cellSize;
          double centerY = (row + 0.5) * cellSize;
          canvas.drawCircle(
              Offset(centerX, centerY), cellSize * 0.4, stonePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
