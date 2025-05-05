import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:stone_war/games/yuk_mok/yuk_mok_about_game.dart';

GlobalKey _viewKey = GlobalKey();
GlobalKey _viewKey2 = GlobalKey();

class YukMokMultiplay extends StatefulWidget {
  final String gameId;
  final int player;
  const YukMokMultiplay(
      {super.key, required this.gameId, required this.player});

  @override
  State<YukMokMultiplay> createState() => _YukMokMultiPlayState();
}

class _YukMokMultiPlayState extends State<YukMokMultiplay> {
  double _top = -200;
  double _left = -170;
  late int chaksu;
  static const int boardSize = 19; // 19x19 판
  static const double cellSize = 40.0; // 셀 크기
  List<List<int>> board =
      List.generate(boardSize, (_) => List.filled(boardSize, 0));
  int currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  bool isGameOver = false;
  bool wating = false;

  int winner = 0;
  List<String> player = ['무', '흑돌', '백돌'];
  // 2차원 배열로 바둑판 상태 관리 (0: 빈칸, 1: 흑돌, 2: 백돌)
  Map<String, dynamic> playerNames = {};
  List<int> lastPosition = [-1, -1];
  Map<String, dynamic>? userInfo1;
  Map<String, dynamic>? userInfo2;

//소리 재생 부분
  final AudioPlayer audioPlayer = AudioPlayer();
  final buttonThrottle = Throttle<List<int>>(
    Duration(seconds: 2, milliseconds: 800),
    initialValue: [-1, -1],
  );

  @override
  void dispose() {
    buttonThrottle.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    buttonThrottle.values.listen((value) {
      print(value);
      if (value == [-1, -1] || widget.player != currentStone) {
        return;
      }
      chaksu++;
      playSound(audioPlayer);
      setState(() {
        if (chaksu > 1) {
          currentStone = 3 - currentStone; // 흑돌(1)과 백돌(2) 전환
          chaksu = 0;
          board[value[0]][value[1]] = widget.player;
          Future.delayed(Duration(seconds: 1), () {
            updateBoard(widget.gameId, board, currentStone, value, 3);
          });
        } else {
          board[value[0]][value[1]] = widget.player;
          updateBoard(widget.gameId, board, widget.player, value, 3);
        }

        winner = checkWinner(board, lastPosition[0], lastPosition[1]);
        if (winner != 0) {
          updateWinner(widget.gameId, winner, 3);
          isGameOver = true;
        }
        lastPosition = [-1, -1];
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getSizes();
    });

    chaksu = widget.player % 2;
    FirebaseFirestore.instance
        .collection('yuk_mok')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> players =
          Map<String, dynamic>.from(gameData["players"]);

      List<int> flattenedBoard = List<int>.from(gameData["board"]);
      List<List<int>> newBoard = List.generate(
          19, (i) => flattenedBoard.sublist(i * 19, (i + 1) * 19));
      int realWinner = gameData["winner"] ?? 0;

      if (board != newBoard ||
          currentStone != gameData['currentTurn'] ||
          winner != 0) {
        snapshot = (await loadUserData(players, "player1"))!;

        userInfo1 = snapshot.data() as Map<String, dynamic>; // 명시적 타입 캐스팅

        snapshot = (await loadUserData(players, "player2"))!;
        if (snapshot.exists) {
          userInfo2 = snapshot.data() as Map<String, dynamic>; // 명시적 타입 캐스팅
        }
        setState(() {
          board = newBoard;
          winner = realWinner;
          currentStone = gameData['currentTurn'];
          playerNames = players;
          if (winner != 0) {
            isGameOver = true;
          }
        });
      }
    });
  }

  late double boardx;
  late double boardy;
  late double boardWidth = cellSize * 15;
  late double boardHeight;

  _getSizes() {
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
    int row = ((position.dy - 75 + 20) / cellSize).floor(); // 클릭된 행 계산
    int col = ((position.dx - 39 + 20) / cellSize).floor(); // 클릭된 열 계산
    //print(position);
    if (row < 0 || col < 0 || row > boardSize - 1 || col > boardSize - 1) {
      return;
    }
    if (board[row][col] == 0) {
      // 빈칸에만 돌을 놓을 수 있음
      final listEquality = ListEquality();

      if (listEquality.equals(lastPosition, [row, col]) &&
          widget.player == currentStone &&
          wating == false) {
        buttonThrottle.setValue([row, col]);
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
    return Scaffold(
      backgroundColor: const Color(0xFFD9BBA0),
      appBar: AppBar(
        title: Text(
          '육목',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        backgroundColor: const Color(0xFFD8E6F2),
      ),
      body: Stack(
        children: [
          Positioned(
            key: _viewKey,
            top: _top,
            left: _left,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _top = (screenHeight > boardHeight)
                      ? (_top + details.delta.dy).clamp(-screenHeight * 0.36,
                          screenHeight - boardHeight) //판보다 화면이 클 때
                      : (_top + details.delta.dy)
                          .clamp(-boardHeight / 2 - 180, 0);
                  _left = (screenWidth > boardWidth)
                      ? (_left + details.delta.dx)
                          .clamp(0, screenWidth - boardWidth) //판보다 화면이 클 때
                      : (_left + details.delta.dx)
                          .clamp(-boardWidth / 2, boardWidth / 4);
                });
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          RenderBox renderBox =
                              context.findRenderObject() as RenderBox;
                          Offset localPosition =
                              renderBox.globalToLocal(details.globalPosition);

                          // 클릭 위치를 바둑판 좌표로 변환, 외부 GestureDetector 이동 반영
                          if (!isGameOver) {
                            _placeStone(Offset(localPosition.dx - _left,
                                localPosition.dy - _top));
                          } // 클릭 위치를 바둑판 좌표로 변환
                        },
                        child: CustomPaint(
                          size:
                              Size(cellSize * boardSize, cellSize * boardSize),
                          painter: YukBoardPainter(board),
                        ),
                      ),
                    ],
                  ),
                  isGameOver
                      ? Text(
                          '${player[winner]} 승!',
                          style:
                              const TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                        )
                      : currentStone == 2
                          ? const Text(
                              '백돌 턴',
                              style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                            )
                          : const Text(
                              '흑돌 턴',
                              style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                            ),
                  PlayersProfile(
                    viewKey: _viewKey2,
                    userInfo1: userInfo1,
                    userInfo2: userInfo2,
                    type: 3,
                  ),
                  ShowGameLog(
                    gameId: widget.gameId,
                    player: player,
                    context: context,
                    type: 3,
                  ),
                  ShowGameId(
                    gameId: widget.gameId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
