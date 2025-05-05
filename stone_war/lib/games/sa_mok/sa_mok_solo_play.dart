import 'package:collection/collection.dart';
import 'package:stone_war/games/sa_mok/sa_mok_about_game.dart';

final GlobalKey _viewKey = GlobalKey();

class SaMokSoloPlay extends StatefulWidget {
  @override
  SaMokSoloPlayState createState() => SaMokSoloPlayState();
  const SaMokSoloPlay({super.key});
}

class SaMokSoloPlayState extends State<SaMokSoloPlay> {
  static const int boardSize = 7; // 7x7 판
  double cellSize = (kIsWeb) ? 80.0 : 40; // 셀 크기
  int gravityDirection = 0;
  bool isGameOver = false;

  int winner = 0;
  List<String> player = ['무', '흑돌', '백돌'];
  // 2차원 배열로 바둑판 상태 관리 (0: 빈칸, 1: 흑돌, 2: 백돌)
  List<List<int>> board =
      List.generate(boardSize - 1, (_) => List.filled(boardSize, 0));

  List<int> lastPosition = [-1, -1];
  int currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  final AudioPlayer audioPlayer = AudioPlayer(); // AudioPlayer 객체 생성

  void beforeStart() {
    gravityDirection = 0;

    isGameOver = false;
    winner = 0;
    board = List.generate(boardSize - 1, (_) => List.filled(boardSize, 0));
    lastPosition = [-1, -1];
    currentStone = 1; // 현재 돌 (1: 흑돌, 2: 백돌)
  }

  @override
  void initState() {
    super.initState();

    beforeStart();
  }

  late double availableWidth;
  // 클릭된 위치를 계산하고 돌 놓기
  void _placeStone(Offset position) {
    int row = ((position.dy) / cellSize).floor(); // 클릭된 행 계산
    int col = ((position.dx) / cellSize).floor(); // 클릭된 열 계산
    //print(position);
    //print(cellSize);
    if (row < 0 || col < 0 || row > boardSize - 2 || col > boardSize - 1) {
      return;
    }
    //print(board);
    if (board[row][col] == 0) {
      // 빈칸에만 돌을 놓을 수 있음
      final listEquality = ListEquality();

      if (listEquality.equals(lastPosition, [row, col])) {
        playSound(audioPlayer);
        lastPosition = [-1, -1];
        setState(() {
          board[row][col] = currentStone;
          currentStone = 3 - currentStone; // 흑돌(1)과 백돌(2) 전환
          gravity(gravityDirection, board);
          //print(board);
          for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 7; j++) {
              winner = check(i, j, board, 4);
              if (winner != 0) {
                //print('승자는 ${player[winner]}');
                isGameOver = true;
              }
            }
          }
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
          "사목 혼자하기",
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
      body: Center(
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
    );
  }
}
