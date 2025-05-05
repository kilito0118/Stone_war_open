import 'package:flutter/material.dart';
import 'package:stone_war/menus/my_page.dart';

class UserIcon extends StatefulWidget {
  final String userSkin;

  const UserIcon({super.key, required this.userSkin});
  @override
  State<StatefulWidget> createState() => _UserIconState();
}

class _UserIconState extends State<UserIcon> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      onPressed: () {
        if (!mounted) return;
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "보유한 스킨 목록",
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.7, // 팝업 창 높이 설정
                child: MyPage(),
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
        child: Image(
          image: AssetImage(["assets/images/", widget.userSkin].join()),
          height: 100.0,
          width: 100.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
