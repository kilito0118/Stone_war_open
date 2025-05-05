import 'package:flutter/material.dart';
import 'package:stone_war/const/color.dart';

class PlayersProfile extends StatefulWidget {
  final Key viewKey;
  final Map<String, dynamic>? userInfo1;
  final Map<String, dynamic>? userInfo2;
  final int type;
  const PlayersProfile({
    super.key,
    required this.viewKey,
    required this.userInfo1,
    required this.userInfo2,
    required this.type,
  });

  @override
  State<PlayersProfile> createState() => _PlayersProfileState();
}

class _PlayersProfileState extends State<PlayersProfile> {
  @override
  Widget build(BuildContext context) {
    //print(widget.userInfo1);
    return Center(
      key: widget.viewKey,
      child: SizedBox(
        width: 960,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 455,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      if (!mounted) return;
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("경기 기록"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: MediaQuery.of(context).size.height *
                                  0.7, // 팝업 창 높이 설정
                              child: ListView.builder(
                                itemCount:
                                    widget.userInfo1?['playerSkins'].length,
                                itemBuilder: (context, index) {
                                  var log =
                                      widget.userInfo1?['playerSkins'][index];
                                  return ListTile(
                                    contentPadding:
                                        EdgeInsets.all(8), // 내부 여백 조정
                                    leading: CircleAvatar(
                                      backgroundColor: boardColor,
                                      child: ClipOval(
                                        child: Image(
                                          image: AssetImage(
                                              ["assets/images/", log].join()),
                                          height: 180.0,
                                          width: 180.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text("타이틀입니다."),
                                    subtitle: Text("서브타이틀입니다."),
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
                    },
                    child: ClipOval(
                      child: widget.userInfo1?["playerSkin"] != null
                          ? Image(
                              image: AssetImage([
                                "assets/images/",
                                widget.userInfo1?["playerSkin"]
                              ].join()),
                              height: 100.0,
                              width: 100.0,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.account_circle_outlined,
                              color: Colors.black, size: 100),
                    ),
                  ),
                  Text('흑돌'),
                  Text("${widget.userInfo1?["nickName"] ?? "들어오는중"}"),
                ], //!!
              ),
            ),
            SizedBox(
              width: 50,
            ),
            SizedBox(
              width: 455,
              child: Column(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      if (!mounted) return;
                      showDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("경기 기록"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: MediaQuery.of(context).size.height *
                                  0.7, // 팝업 창 높이 설정
                              child: ListView.builder(
                                itemCount:
                                    widget.userInfo1?['playerSkins'].length,
                                itemBuilder: (context, index) {
                                  var log =
                                      widget.userInfo1?['playerSkins'][index];
                                  return ListTile(
                                    contentPadding:
                                        EdgeInsets.all(8), // 내부 여백 조정
                                    leading: CircleAvatar(
                                      backgroundColor: boardColor,
                                      child: ClipOval(
                                        child: Image(
                                          image: AssetImage(
                                              ["assets/images/", log].join()),
                                          height: 180.0,
                                          width: 180.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text("타이틀입니다."),
                                    subtitle: Text("서브타이틀입니다."),
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
                    },
                    child: ClipOval(
                      child: widget.userInfo2?["playerSkin"] != null
                          ? Image(
                              image: AssetImage([
                                "assets/images/",
                                widget.userInfo2?["playerSkin"]
                              ].join()),
                              height: 100.0,
                              width: 100.0,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.account_circle_outlined,
                              color: Colors.black, size: 100),
                    ),
                  ),
                  Text(widget.type <= 1 ? "적돌" : '백돌'),
                  Text("${widget.userInfo2?["nickName"] ?? "들어오는중"}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
