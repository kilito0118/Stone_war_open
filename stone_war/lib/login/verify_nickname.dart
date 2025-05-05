import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<bool> isNicknameAvailable(String nickname) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('nickname', isEqualTo: nickname)
      .get();
  //print(snapshot.docs.isEmpty);
  return snapshot.docs.isEmpty;
}

class VerifyNickname extends StatefulWidget {
  final TextEditingController controller;
  const VerifyNickname({
    super.key,
    required this.controller,
  });
  @override
  VerifyNicknameState createState() => VerifyNicknameState();
}

bool ischeck = false;
bool isfirst = false;
String lastNickname = "";

class VerifyNicknameState extends State<VerifyNickname> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_textChanged);
  }

  void _textChanged() {
    if (widget.controller.text != lastNickname) {
      setState(() {
        isfirst = false;
        ischeck = false;
        lastNickname = widget.controller.text;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textChanged);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: ischeck == true
              ? null
              : () {
                  setState(() {});
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() async {
                      isfirst = true;
                      ischeck =
                          await isNicknameAvailable(widget.controller.text);
                    });
                  });
                },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) return Colors.grey;
                if (states.contains(WidgetState.hovered)) {
                  return Colors.blue[200]!;
                }
                return Colors.transparent; // 기본
              },
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '✔️',
                  style: TextStyle(
                    fontFamily: 'NotoEmoji', // 이모지를 지원하는 폰트를 지정
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: '중복 확인하기',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                TextSpan(
                  text: '✔️',
                  style: TextStyle(
                    fontFamily: 'NotoEmoji', // 이모지를 지원하는 폰트를 지정
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        isfirst == false
            ? Container(
                padding: EdgeInsets.all(8), // 여백 설정
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 71, 66, 215), // 배경색 지정
                  borderRadius: BorderRadius.circular(5), // 모서리 둥글게 설정
                ),
                child: Text(
                  '중복 확인을 해주세요!',
                  style: Theme.of(context).textTheme.displayLarge,
                  selectionColor: Colors.white,
                ),
              )
            : ischeck == true
                ? Container(
                    padding: EdgeInsets.all(8), // 여백 설정
                    decoration: BoxDecoration(
                      color: const Color(0xFF69F0AE), // 배경색 지정
                      borderRadius: BorderRadius.circular(5), // 모서리 둥글게 설정
                    ),
                    child: Text(
                      '사용 가능한 닉네임입니다!',
                      style: Theme.of(context).textTheme.displayLarge,
                      selectionColor: Colors.white,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(8), // 여백 설정
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252), // 배경색 지정
                      borderRadius: BorderRadius.circular(5), // 모서리 둥글게 설정
                    ),
                    child: Text(
                      '불가능한 닉네임입니다...',
                      style: Theme.of(context).textTheme.displayLarge,
                      selectionColor: Colors.white,
                    ),
                  ),
      ],
    );
  }
}
