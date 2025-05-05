import 'package:stone_war/games/game_components/about_multi.dart';
import 'sa_mok_about_game.dart';

final GlobalKey _viewKey = GlobalKey();

GlobalKey _viewKey2 = GlobalKey();

class SaMokMultiplay extends StatefulWidget {
  final String gameId;
  final int player;
  @override
  SaMokMultiplayState createState() => SaMokMultiplayState();
  const SaMokMultiplay({
    super.key,
    required this.gameId,
    required this.player,
  });
}

class SaMokMultiplayState extends State<SaMokMultiplay> {
  static const int boardSize = 7; // 7x7 판
  double cellSize = (kIsWeb) ? 80.0 : 40; // 셀 크기
  int gravityDirection = 0;
  bool isGameOver = false;
  Map<String, dynamic>? userInfo1;
  Map<String, dynamic>? userInfo2;
  int winner = 0;
  List<String> player = ['무', '흑돌', '백돌'];
  // 2차원 배열로 바둑판 상태 관리 (0: 빈칸, 1: 흑돌, 2: 백돌)
  Map<String, dynamic> playerNames = {};
  List<List<int>> board =
      List.generate(boardSize - 1, (_) => List.filled(boardSize, 0));

  List<int> lastPosition = [-1, -1];
  int currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  final AudioPlayer audioPlayer = AudioPlayer(); // AudioPlayer 객체 생성
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
      if (value == [-1, -1] || widget.player != currentStone) {
        return;
      }
      playSound(audioPlayer);
      setState(() {
        board[value[0]][value[1]] = widget.player;

        // currentStone = 3 - currentStone; // 흑돌(1)과 백돌(2) 전환
        gravity(gravityDirection, board);
        //print(board);
        updateBoard(widget.gameId, board, 3 - widget.player, value, 1);
        for (int i = 0; i < 6; i++) {
          for (int j = 0; j < 7; j++) {
            winner = check(i, j, board, 4);
            if (winner != 0) {
              //print('승자는 ${player[winner]}');
              isGameOver = true;
            }
          }
        }
        updateWinner(widget.gameId, winner, 1);
      });
    });

    FirebaseFirestore.instance
        .collection('sa_mok')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> players =
          Map<String, dynamic>.from(gameData["players"]);

      List<int> flattenedBoard = List<int>.from(gameData["board"]);
      List<List<int>> newBoard =
          List.generate(6, (i) => flattenedBoard.sublist(7 * i, (7) * (i + 1)));

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

  late double availableWidth;
  // 클릭된 위치를 계산하고 돌 놓기
  void _placeStone(Offset position) {
    int row = ((position.dy) / cellSize).floor(); // 클릭된 행 계산
    int col = ((position.dx) / cellSize).floor(); // 클릭된 열 계산
    print(position);
    print(cellSize);
    if (row < 0 || col < 0 || row > boardSize - 2 || col > boardSize - 1) {
      return;
    }
    //print(board);
    if (board[row][col] == 0) {
      // 빈칸에만 돌을 놓을 수 있음
      final listEquality = ListEquality();

      if (listEquality.equals(lastPosition, [row, col])) {
        buttonThrottle.setValue([row, col]);
        lastPosition = [-1, -1];
      } else {
        setState(() {
          board[row][col] = -1;

          gravity(gravityDirection, board);
          lastPosition[0] = row;
          lastPosition[1] = col;
        });
      }
    }
    //print(board);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height - 130;
    availableWidth = min(screenHeight, screenWidth) - 128;
    if (screenWidth < 432) {
      cellSize = 40;
    }

    print(availableWidth);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          "사목 같이하기",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => performLogout(context),
            child: Text(
              "로그아웃",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: GestureDetector(
                        key: _viewKey,
                        onTapDown: (TapDownDetails details) {
                          final RenderBox box = _viewKey.currentContext
                              ?.findRenderObject() as RenderBox;
                          final Offset localPosition =
                              box.globalToLocal(details.globalPosition);

                          if (!isGameOver) {
                            _placeStone(localPosition);
                          } // 클릭 위치를 바둑판 좌표로 변환
                        },
                        child: CustomPaint(
                          size: Size(
                              cellSize * boardSize, cellSize * (boardSize - 1)),
                          painter: SaBoardPainter(board, boardSize),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              BlinkingArrow(
                direction: 0,
              ),
              isGameOver == true
                  ? Text(
                      '${player[3 - currentStone]} 승!',
                      style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                    )
                  : currentStone == 2
                      ? Text(
                          '적돌 턴',
                          style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                        )
                      : Text(
                          '흑돌 턴',
                          style: TextStyle(fontSize: 28, fontFamily: '힘찬체'),
                        ),
              PlayersProfile(
                viewKey: _viewKey2,
                userInfo1: userInfo1,
                userInfo2: userInfo2,
                type: 1,
              ),
              TextButton(
                onPressed: () =>
                    showMatchLogDialog(context, widget.gameId, 1, player),
                child: Text(
                  "기보 보기",
                  style: TextStyle(color: mainColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.gameId));
                },
                child: Text(
                  "방 아이디:${widget.gameId}\n눌러서 복사",
                  style: TextStyle(fontFamily: '', color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
