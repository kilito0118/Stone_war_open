// 바둑판과 돌을 그리는 CustomPainter
import 'package:flutter/material.dart';
export 'package:stone_war/games/check/game_sa_mok.dart';
export 'package:stone_war/games/game_components/about_game.dart';
export 'package:stone_war/games/game_components/blink_arrow.dart';
export 'package:stone_war/const/color.dart';
export 'package:audioplayers/audioplayers.dart';
export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'dart:math';
export 'package:stone_war/login/logout.dart';
export 'package:stone_war/games/game_components/players_profile.dart';
export 'package:flutter/services.dart';

class SaBoardPainter extends CustomPainter {
  final List<List<int>> board;
  final int orginalBoardSize;
  SaBoardPainter(this.board, this.orginalBoardSize);

  @override
  void paint(Canvas canvas, Size size) {
    int boardSize = orginalBoardSize;
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    double cellSize = size.width / orginalBoardSize;
    //double boardType = 20.0;

    // 바둑판 그리기
    for (int i = 0; i < boardSize + 1; i++) {
      double offset = i * cellSize; //바둑판이면 20을 더하기
      if (i != boardSize) {
        canvas.drawLine(
            Offset(0, offset), Offset(size.width, offset), linePaint); // 가로선
      }
      canvas.drawLine(
          Offset(offset, 0), Offset(offset, size.height), linePaint); // 세로선
    }

    // 돌 그리기
    for (int row = 0; row < boardSize - 1; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] != 0) {
          Paint stonePaint = Paint()
            ..color = board[row][col] == 1
                ? Colors.black
                : board[row][col] == 2
                    ? Colors.red
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
