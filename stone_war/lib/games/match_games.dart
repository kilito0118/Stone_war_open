import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stone_war/const/color.dart';
import 'package:stone_war/games/game_components/about_multi.dart';
import 'package:stone_war/games/o_mok/o_mok_multiplay.dart';
import 'package:stone_war/games/sa_mok/sa_mok_multiplay.dart';
import 'package:stone_war/games/yuk_mok/yuk_mok_multiplay.dart';
import 'package:stone_war/home_screen.dart';
import 'package:stone_war/login/logout.dart';
import 'package:stone_war/menus/my_page.dart';

Future<String> createGameRoom(String userId, int type) async {
  List<List<int>> board = List.generate(15, (_) => List.generate(15, (_) => 0));
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('dol_mok').doc();
  switch (type) {
    case 0:
      gameRef = FirebaseFirestore.instance.collection('dol_mok').doc();
      board = List.generate(15, (_) => List.generate(15, (_) => 0));
      break;
    case 1:
      gameRef = FirebaseFirestore.instance.collection('sa_mok').doc();
      board = List.generate(6, (_) => List.generate(7, (_) => 0));
      break;
    case 2:
      gameRef = FirebaseFirestore.instance.collection('o_mok').doc();
      board = List.generate(15, (_) => List.generate(15, (_) => 0));
      break;
    case 3:
      gameRef = FirebaseFirestore.instance.collection('yuk_mok').doc();
      board = List.generate(19, (_) => List.generate(19, (_) => 0));
      break;
  }

  // 2차원 배열을 1차원으로 변환
  List<int> flattenedBoard = flattenBoard(board);

  // Firestore에 저장
  Map<String, dynamic> gameData = {
    "board": flattenedBoard,
    "currentTurn": 1,
    "players": {"player1": userId, "player2": null},
    "createdAt": FieldValue.serverTimestamp(),
    "winner": null,
    "matchLog": [],
  };

  await gameRef.set(gameData);
  return gameRef.id;
}

Future<int> joinGameRoom(String gameId, String userId, int type) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('o_mok').doc(gameId);

  switch (type) {
    case 0:
      gameRef = FirebaseFirestore.instance.collection('dol_mok').doc(gameId);
      break;
    case 1:
      gameRef = FirebaseFirestore.instance.collection('sa_mok').doc(gameId);
      break;
    case 2:
      gameRef = FirebaseFirestore.instance.collection('o_mok').doc(gameId);
      break;
    case 3:
      gameRef = FirebaseFirestore.instance.collection('yuk_mok').doc(gameId);
      break;
  }
  DocumentSnapshot snapshot = await gameRef.get();
  if (!snapshot.exists) {
    return 0; // 방이 존재하지 않음
  }

  Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
  Map<String, String?> players = Map<String, String?>.from(gameData['players']);

  if (players["player1"] == userId) {
    //재참여
    return 1; // 방에 성공적으로 참여
  } else if (players["player2"] == null || players["player2"] == userId) {
    players["player2"] = userId;
    await gameRef.update({"players": players});
    return 2; // 이미 player2가 존재함
  } else {
    return 0;
  }
}

class MatchGames extends StatefulWidget {
  //0 돌목, 1 사목, 2 오목, 3 육목
  final int type;
  const MatchGames({super.key, required this.type});
  @override
  State<StatefulWidget> createState() => _MatchGamesState();
}

bool isfoucsed = false;

class _MatchGamesState extends State<MatchGames> {
  String? gameId;
  String userId = ''; // 테스트용 사용자 ID
  static TextEditingController gameIdController = TextEditingController();
  String message = "";
  DocumentSnapshot? userInfo;
  String gameTitle = "";

  static const List<String> gameTitles = ["돌목", "사목", "오목", "육목"];
  static const List<Color> gameColors = [
    Color(0xFFBBF08E),
    Color(0xFF3AB77F),
    Color(0xFF546E7A),
    Color(0xFFF08E41),
  ];

  @override
  void initState() {
    super.initState();

    loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userId = user.uid;
        userInfo = doc;
      });
      // ignore: unused_catch_clause
    } on FirebaseException catch (e) {
      print('Firestore Error: ${e.code}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //print(screenWidth);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          "${gameTitles[widget.type]} 게임",
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
      backgroundColor: gameColors[widget.type],
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (screenWidth >= 1130) ...[
              SizedBox(width: 90),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('레이팅 매치 하기'),
                    MyPage(),
                  ],
                ),
              ),
              SizedBox(width: 90),
            ] else ...[
              Flexible(flex: 1, child: Text("")),
            ],
            Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (screenWidth < 1130) ...[
                    Text('레이팅 매치 하기'),
                    TextButton(onPressed: () {}, child: Text("매칭 시작")),
                    Text("${gameTitles[widget.type]} 레이팅 : "),
                    //MyPage(),
                  ],
                  Text("친구랑 하기"),
                  ElevatedButton(
                    onPressed: () async {
                      String newGameId =
                          await createGameRoom(userId, widget.type);
                      setState(() {
                        gameId = newGameId;
                        message = "게임 방이 생성되었습니다. \n코드: $newGameId";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              switch (widget.type) {
                                case 0:
                                  return OMokMultiplay(
                                    gameId: gameId!,
                                    player: 1,
                                  );
                                case 1:
                                  return SaMokMultiplay(
                                    gameId: gameId!,
                                    player: 1,
                                  );
                                case 2:
                                  return OMokMultiplay(
                                    gameId: gameId!,
                                    player: 1,
                                  );
                                case 3:
                                  return YukMokMultiplay(
                                    gameId: gameId!,
                                    player: 1,
                                  );
                                case _:
                                  return HomeScreen();
                              }
                            },
                          ),
                        );
                      });
                    },
                    child: Text("방 만들기"),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    expands: false,
                    controller: gameIdController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      focusColor: const Color(0xFFD8E6F2),
                      hoverColor: Colors.transparent,
                      fillColor: mainColor,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.zero),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 4,
                          style: BorderStyle.solid,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      label: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "초대 코드 입력",
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (gameIdController.text.isEmpty == false) {
                        int success = await joinGameRoom(
                            gameIdController.text, userId, widget.type);
                        setState(() {
                          message = (success == 1 || success == 2)
                              ? "방에 참여했습니다!"
                              : "방에 참여할 수 없습니다.";
                          if (success != 0) {
                            switch (widget.type) {
                              case 0:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OMokMultiplay(
                                      gameId: gameIdController.text,
                                      player: success,
                                    ),
                                  ),
                                );
                                break;
                              case 1:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaMokMultiplay(
                                      gameId: gameIdController.text,
                                      player: success,
                                    ),
                                  ),
                                );
                                break;
                              case 2:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OMokMultiplay(
                                      gameId: gameIdController.text,
                                      player: success,
                                    ),
                                  ),
                                );
                                break;
                              case 3:
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => YukMokMultiplay(
                                      gameId: gameIdController.text,
                                      player: success,
                                    ),
                                  ),
                                );
                                break;
                            }
                          }
                        });
                      }
                    },
                    child: Text("방 참여하기"),
                  ),
                  SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
            if (screenWidth >= 1130) SizedBox(width: 90),
          ],
        ),
      ),
    );
  }
}
