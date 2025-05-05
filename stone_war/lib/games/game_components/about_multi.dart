import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

export 'package:debounce_throttle/debounce_throttle.dart';
export 'package:cloud_firestore/cloud_firestore.dart';

List<String> gameType = ["dol_mok", "sa_mok", "o_mok", "yuk_mok"];

List<int> flattenBoard(List<List<int>> board) {
  return board.expand((row) => row).toList();
}

List<List<int>> unflattenBoard(
    List<int> flatBoard, int rowCount, int colCount) {
  return List.generate(
      rowCount, (i) => flatBoard.sublist(i * colCount, (i + 1) * colCount));
}

Future<List<List<int>>> getBoard(String gameId, int type) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(gameType[type])
      .doc(gameId)
      .get();

  if (!snapshot.exists) {
    throw Exception("게임 방을 찾을 수 없습니다.");
  }

  Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;

  // Firestore에서 불러온 1차원 배열
  List<int> flattenedBoard = List<int>.from(gameData["board"]);

  // 1차원 배열을 2차원으로 변환
  return unflattenBoard(flattenedBoard, 15, 15);
}

Future<void> updateWinner(String gameId, int winner, int type) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection(gameType[type]).doc(gameId);
  await gameRef.update({"winner": winner});
}

Future<void> updateBoard(String gameId, List<List<int>> board, int currentTurn,
    List<int> lastPosition, int type) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection(gameType[type]).doc(gameId);

  // 2차원 배열을 1차원으로 변환 (Firestore는 중첩 배열을 지원하지 않음)
  List<int> flattenedBoard = board.expand((row) => row).toList();

  // Firestore에 저장
  await gameRef.update({"board": flattenedBoard});
  await gameRef.update({"currentTurn": currentTurn});
  await gameRef.update({
    "matchLog": FieldValue.arrayUnion([
      {
        "player": 3 - currentTurn,
        "x": lastPosition[0],
        "y": lastPosition[1],
        "timestamp": DateTime.now()
      }
    ])
  });
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
}
