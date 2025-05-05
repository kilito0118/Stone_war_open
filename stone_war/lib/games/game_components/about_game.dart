import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stone_war/const/color.dart';

import 'about_multi.dart';

Future<DocumentSnapshot<Map<String, dynamic>>?> loadUserData(
    Map<String, dynamic> players, String type) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  try {
    final doc1 = await FirebaseFirestore.instance
        .collection('users')
        .doc(players[type])
        .get();
    //print(doc1);
    return doc1;

    // ignore: unused_catch_clause
  } on FirebaseException catch (e) {
    print('Firestore Error: ${e.code}');
  }
  return null;
}

void showMatchLogDialog(
    BuildContext context, String gameId, int type, List<String> player) async {
  List<Map<String, dynamic>> matchLog = await getMatchLog(gameId, type);

  showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("경기 기록"),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7, // 팝업 창 높이 설정
          child: matchLog.isEmpty
              ? Center(child: Text("경기 기록이 없습니다."))
              : ListView.builder(
                  itemCount: matchLog.length,
                  itemBuilder: (context, index) {
                    var log = matchLog[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: boardColor,
                        child: log["player"] == 1
                            ? Icon(Icons.circle, color: Colors.black)
                            : Icon(Icons.circle, color: Colors.white),
                      ),
                      title: Text(
                          "${player[log['player']]} (${log['x']}, ${log['y']})에 착수"),
                      subtitle:
                          Text("시간: ${formatTimestamp(log['timestamp'])}"),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("닫기"),
          ),
        ],
      );
    },
  );
}

Future<List<Map<String, dynamic>>> getMatchLog(String gameId, int type) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(gameType[type])
      .doc(gameId)
      .get();

  if (!snapshot.exists) {
    throw Exception("게임을 찾을 수 없습니다.");
  }

  Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;

  if (!gameData.containsKey("matchLog")) {
    return []; // matchLog가 없으면 빈 리스트 반환
  }

  // Firestore에서 가져온 matchLog를 List<Map<String, dynamic>>으로 변환
  List<Map<String, dynamic>> matchLog =
      List<Map<String, dynamic>>.from(gameData["matchLog"]);

  return matchLog;
}

Future<void> playSound(AudioPlayer audioPlayer) async {
  await audioPlayer.play(AssetSource('audios/착수.mp3'));
}

class ShowGameLog extends StatefulWidget {
  final String gameId;
  final List<String> player;
  final BuildContext context;
  final int type;
  const ShowGameLog({
    super.key,
    required this.gameId,
    required this.player,
    required this.context,
    required this.type,
  });

  @override
  State<ShowGameLog> createState() => ShowGameLogState();
}

class ShowGameLogState extends State<ShowGameLog> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showMatchLogDialog(
          widget.context, widget.gameId, widget.type, widget.player),
      child: Text(
        "기보 보기",
        style: TextStyle(color: mainColor),
      ),
    );
  }
}

class ShowGameId extends StatelessWidget {
  final String gameId;
  const ShowGameId({super.key, required this.gameId});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: gameId));
      },
      child: Text(
        "방 아이디:$gameId\n눌러서 복사",
        style: TextStyle(fontFamily: '', color: systemColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
