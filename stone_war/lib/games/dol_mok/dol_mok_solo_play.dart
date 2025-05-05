import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:stone_war/games/check/game_dol_mok.dart';
import 'blink_arrow.dart';
import 'package:stone_war/const/color.dart';
import 'package:audioplayers/audioplayers.dart';

GlobalKey _viewKey = GlobalKey();

class DolMokSoloPlay extends StatefulWidget {
  @override
  DolMokSoloPlayState createState() => DolMokSoloPlayState();
  const DolMokSoloPlay({super.key});
}

late double cellSize;
late double availableWidth;

class DolMokSoloPlayState extends State<DolMokSoloPlay> {
  static const int boardSize = 7; // 7x7 판
  //static double cellSize = 40.0; // 셀 크기
  int gravityDirection = 0;
  bool isGameOver = false;
  bool isWaiting = false;
  int winner = 0;
  List<String> player = ['무', '흑돌', '백돌'];
  // 2차원 배열로 바둑판 상태 관리 (0: 빈칸, 1: 흑돌, 2: 백돌)
  List<List<int>> board =
      List.generate(boardSize, (_) => List.filled(boardSize, 0));
  List<int> lastPosition = [-1, -1];
  int currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  final AudioPlayer _audioPlayer = AudioPlayer(); // AudioPlayer 객체 생성

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.play(AssetSource(fileName)); // 로컬 파일 재생
  }

  void beforeStart() {
    gravityDirection = 0;
    isWaiting = false;
    isGameOver = false;
    winner = 0;
    board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    lastPosition = [-1, -1];
    currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getSize();
    });
    beforeStart();
  }

  late double boardx;
  late double boardy;
  late double boardWidth;
  late double boardHeight;
  _getSize() {
    final context = _viewKey.currentContext;
    if (context != null) {
      RenderBox viewBox = context.findRenderObject() as RenderBox;
      Offset offset = viewBox.localToGlobal(Offset.zero);

      boardx = offset.dx;
      boardy = offset.dy;
      boardWidth = viewBox.size.width;
      boardHeight = viewBox.size.height;
    } else {
      // currentContext가 null인 경우, 로깅하거나 재시도하는 등의 처리를 합니다.
      debugPrint("Warning: _viewKey.currentContext is null");
    }
  }

  // 클릭된 위치를 계산하고 돌 놓기
  void _placeStone(Offset position) {
    int row = ((position.dy) / cellSize).floor(); // 클릭된 행 계산
    int col = ((position.dx) / cellSize).floor(); // 클릭된 열 계산

    //print(position);
    //print(row);
    //print(col);
    if (row < 0 || col < 0 || row > boardSize - 1 || col > boardSize - 1) {
      return;
    }
    if (board[row][col] == 0 && isWaiting != true) {
      // 빈칸에만 돌을 놓을 수 있음
      final listEquality = ListEquality();

      if (listEquality.equals(lastPosition, [row, col])) {
        _playSound('audios/착수.mp3');
        lastPosition = [-1, -1];
        setState(() {
          board[row][col] = currentStone;
          currentStone = 3 - currentStone; // 흑돌(1)과 백돌(2) 전환
          gravity(gravityDirection, board);

          for (int i = 0; i < boardSize; i++) {
            for (int j = 0; j < boardSize; j++) {
              winner = check(i, j, board, 4);
              if (winner != 0) {
                //print('승자는 ${player[winner]}');
                isGameOver = true;
                return;
              }
            }
          }

          isWaiting = true;
        });
      } else {
        setState(() {
          board[row][col] = -1;

          gravity(gravityDirection, board);
          lastPosition[0] = row;
          lastPosition[1] = col;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height - 130;

    availableWidth = min(screenHeight, screenWidth) - 128;
    cellSize = availableWidth / boardSize;
    //print(cellSize);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '돌목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Visibility(
            visible: (gravityDirection != 0 && isWaiting == true),
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _playSound('audios/회전.mp3');
                  isWaiting = false;
                  gravityDirection = 2;
                  gravity(gravityDirection, board);
                  for (int i = 0; i < boardSize; i++) {
                    for (int j = 0; j < boardSize; j++) {
                      winner = check(i, j, board, 4);
                      if (winner != 0) {
                        //print('승자는 ${player[winner]}');
                        isGameOver = true;
                      }
                    }
                  }
                });
              },
              style: TextButton.styleFrom(overlayColor: Colors.white),
              child: SizedBox(
                width: 280,
                height: 40,
                child: BlinkingArrow(
                  direction: 2,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: (gravityDirection != 1 && isWaiting == true),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _playSound('audios/회전.mp3');
                      isWaiting = false;
                      gravityDirection = 3;
                      gravity(gravityDirection, board);
                      for (int i = 0; i < boardSize; i++) {
                        for (int j = 0; j < boardSize; j++) {
                          winner = check(i, j, board, 4);
                          if (winner != 0) {
                            //print('승자는 ${player[winner]}');
                            isGameOver = true;
                          }
                        }
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    overlayColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 280,
                    child: BlinkingArrow(
                      direction: 3,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                key: _viewKey,
                onTapDown: (TapDownDetails details) {
                  final RenderBox box =
                      _viewKey.currentContext?.findRenderObject() as RenderBox;
                  final Offset localPosition =
                      box.globalToLocal(details.globalPosition);
                  if (!isGameOver) {
                    _placeStone(localPosition);
                  } // 클릭 위치를 바둑판 좌표로 변환
                },
                child: CustomPaint(
                  size: Size(cellSize * boardSize, cellSize * boardSize),
                  painter: GoBoardPainter(board),
                ),
              ),
              Visibility(
                visible: (gravityDirection != 3 && isWaiting == true),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      isWaiting = false;
                      _playSound('audios/회전.mp3');
                      gravityDirection = 1;
                      gravity(gravityDirection, board);
                      for (int i = 0; i < boardSize; i++) {
                        for (int j = 0; j < boardSize; j++) {
                          winner = check(i, j, board, 4);
                          if (winner != 0) {
                            //print('승자는 ${player[winner]}');
                            isGameOver = true;
                          }
                        }
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    overlayColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 280,
                    child: BlinkingArrow(
                      direction: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: (gravityDirection != 2 && isWaiting == true),
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _playSound('audios/회전.mp3');
                  isWaiting = false;
                  gravityDirection = 0;
                  gravity(gravityDirection, board);
                  for (int i = 0; i < boardSize; i++) {
                    for (int j = 0; j < boardSize; j++) {
                      winner = check(i, j, board, 4);
                      if (winner != 0) {
                        //print('승자는 ${player[winner]}');
                        isGameOver = true;
                      }
                    }
                  }
                });
              },
              style: TextButton.styleFrom(overlayColor: Colors.white),
              child: SizedBox(
                width: 280,
                height: 40,
                child: BlinkingArrow(
                  direction: 0,
                ),
              ),
            ),
          ),
          isGameOver == true
              ? Text(
                  '${player[3 - currentStone]} 승!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                )
              : isWaiting == true
                  ? Text(
                      '돌릴 방향을 눌러주세요',
                      style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                    )
                  : currentStone == 2
                      ? Text(
                          'red 턴',
                          style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                        )
                      : Text(
                          'black 턴',
                          style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                        ),
          isGameOver
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      beforeStart();
                    });
                  },
                  child: Text(
                    '다시 시작하시겠습니까?',
                    style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                  ),
                )
              : Text(''),
        ],
      ),
    );
  }
}

// 바둑판과 돌을 그리는 CustomPainter
class GoBoardPainter extends CustomPainter {
  final List<List<int>> board;

  GoBoardPainter(this.board);

  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    int boardSize = DolMokSoloPlayState.boardSize;
    double cellSize = size.width / boardSize;
    //double boardType = 20.0;

    // 바둑판 그리기
    for (int i = 0; i < boardSize + 1; i++) {
      double offset = i * cellSize;
      canvas.drawLine(
          Offset(0, offset), Offset(size.width + 0, offset), linePaint); // 가로선
      canvas.drawLine(
          Offset(offset, 0), Offset(offset, size.height + 0), linePaint); // 세로선
    }

    // 돌 그리기
    for (int row = 0; row < boardSize; row++) {
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
