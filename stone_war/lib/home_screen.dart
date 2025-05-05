import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stone_war/const/color.dart';
import 'package:stone_war/login/logout.dart';
import 'package:stone_war/menus/game_menus/game_menu.dart';
import 'package:stone_war/menus/my_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController =
      PageController(initialPage: 1); // 페이지 컨트롤러
  int _currentIndex = 1;
  @override
  Widget build(BuildContext context) {
    void handleNavTap(int index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = index);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: brightBoardColor,
        appBar: AppBar(
          title: Text(
            '석전',
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
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
        ),
        body: PageView(
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse, // 웹에서 마우스 드래그 허용
            },
          ),
          physics: const ClampingScrollPhysics(),
          pageSnapping: true,
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            const GameMenu(),
            const GameMenu(),
            MyPage(),
          ], // 각 탭의 화면
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: mainColor,
          selectedItemColor: Colors.black,
          //mouseCursor: MouseCursor.defer,
          selectedFontSize: 20,
          selectedIconTheme: IconThemeData(size: 38, color: Colors.black),
          currentIndex: _currentIndex,
          onTap: handleNavTap,
          items: [
            BottomNavigationBarItem(
              //게임 아이콘을 보여주면 좋을 것 같은데 마땅한 것이 없다.
              //게임 컨트롤러를 보여주어야 하는가?->게임 컨트롤러를 쓰지 않는데 보여주는 것은 마음에 들지 않는다.
              //체닷을 보면 폰을 손으로 잡고 있는 아이콘이다..

              icon: Icon(Icons.join_full_outlined),
              label: '전적 검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports),
              label: '게임하기',
              //activeIcon: Text("하이라이트"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '내 정보',
            ),
          ],
        ),
      ),
    );
  }
}
