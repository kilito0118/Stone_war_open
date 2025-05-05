import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'o_mok_about_game.dart';

GlobalKey _viewKey = GlobalKey();

class OMokSoloPlay extends StatefulWidget {
  const OMokSoloPlay({super.key});

  @override
  State<OMokSoloPlay> createState() => _OMokSoloPlayState();
}

class _OMokSoloPlayState extends State<OMokSoloPlay> {
  double _top = 0;
  double _left = -140;
  static const int boardSize = 15; // 15x15 판
  static const double cellSize = 40.0; // 셀 크기

  bool isGameOver = false;

  int winner = 0;
  List<String> player = ['무', '흑돌', '백돌'];
  // 2차원 배열로 바둑판 상태 관리 (0: 빈칸, 1: 흑돌, 2: 백돌)
  List<List<int>> board =
      List.generate(boardSize, (_) => List.filled(boardSize, 0));
  List<int> lastPosition = [-1, -1];
  int currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)

  void beforeStart() {
    isGameOver = false;
    winner = 0;
    board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    lastPosition = [-1, -1];
    currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  }

//소리 재생 부분
  final AudioPlayer audioPlayer = AudioPlayer();

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
  late double boardWidth = cellSize * 15;
  late double boardHeight;
  _getSize() {
    final context = _viewKey.currentContext;
    if (context != null) {
      RenderBox viewBox = context.findRenderObject() as RenderBox;
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _left = (screenSize.width - viewBox.size.width) / 2;
        _top = (screenSize.height - viewBox.size.height) / 2;
      });
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
    int row = ((position.dy - 56) / cellSize).floor(); // 클릭된 행 계산

    int col = ((position.dx + 40) / cellSize).floor() - 1; // 클릭된 열 계산
    if (row < 0 || col < 0 || row > boardSize - 1 || col > boardSize - 1) {
      return;
    }
    if (board[row][col] == 0) {
      // 빈칸에만 돌을 놓을 수 있음
      final listEquality = ListEquality();

      if (listEquality.equals(lastPosition, [row, col])) {
        playSound(audioPlayer);
        setState(() {
          board[row][col] = currentStone;
          currentStone = 3 - currentStone; // 흑돌(1)과 백돌(2) 전환

          winner = checkWinner(board, lastPosition[0], lastPosition[1]);
          if (winner != 0) {
            isGameOver = true;
          }
          lastPosition = [-1, -1];
        });
      } else {
        setState(() {
          board[row][col] = -1;
          lastPosition[0] = row;
          lastPosition[1] = col;
        });
      }
    }
  }

  late Size lastSize;
  bool firstbuild = true;
  @override
  Widget build(BuildContext context) {
    Size nowSize = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height - 130;
    if (firstbuild == false && lastSize != nowSize) {
      BuildContext? viewKeyContext = _viewKey.currentContext;
      if (viewKeyContext != null) {
        RenderBox viewBox = viewKeyContext.findRenderObject() as RenderBox;
        final screenSize = MediaQuery.of(viewKeyContext).size;
        setState(() {
          _left = (screenSize.width - viewBox.size.width) / 2;
          _top = (screenSize.height - viewBox.size.height) / 2;
        });
      }
    }
    lastSize = nowSize;

    firstbuild = false;
    //print(boardWidth);

    return Scaffold(
      backgroundColor: boardColor,
      appBar: AppBar(
        title: Text(
          '오목 혼자 하기',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: mainColor,
      ),
      body: Stack(
        children: [
          Positioned(
            top: _top,
            left: _left,
            child: GestureDetector(
              onPanUpdate: (details) => setState(
                () {
                  _top = (screenHeight > boardHeight)
                      ? (_top + details.delta.dy)
                          .clamp(0, screenHeight - boardHeight)
                      : (_top + details.delta.dy)
                          .clamp(-boardHeight / 2, 0); //판보다 화면이 클 때
                  _left = (screenWidth > boardWidth)
                      ? (_left + details.delta.dx)
                          .clamp(0, screenWidth - boardWidth)
                      : (_left + details.delta.dx)
                          .clamp(-boardWidth / 2, boardWidth / 4); //판보다 화면이 클 때
                },
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        key: _viewKey,
                        onTapDown: (TapDownDetails details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          Offset localPosition =
                              renderBox.globalToLocal(details.globalPosition);

                          if (!isGameOver) {
                            _placeStone(Offset(localPosition.dx - _left,
                                localPosition.dy - _top));
                          }
                        },
                        child: CustomPaint(
                          size:
                              Size(cellSize * boardSize, cellSize * boardSize),
                          painter: OBoardPainter(board),
                        ),
                      ),
                    ],
                  ),
                  isGameOver == true
                      ? Text(
                          '${player[3 - currentStone]} 승!',
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
            ),
          ),
        ],
      ),
    );
  }
}
