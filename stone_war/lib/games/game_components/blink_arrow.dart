import 'package:flutter/material.dart';

class BlinkingArrow extends StatefulWidget {
  final int direction;

  const BlinkingArrow({
    super.key,
    required this.direction,
  });
  @override
  // ignore: library_private_types_in_public_api
  _BlinkingArrowState createState() => _BlinkingArrowState();
}

class _BlinkingArrowState extends State<BlinkingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  List<String> arrow = ["아래", "오른쪽", "위", "왼쪽"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1), // 깜빡이는 주기
      vsync: this,
    )..repeat(reverse: true); // 애니메이션 반복 (앞뒤로)

    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation, // 투명도 애니메이션 적용
      child: Icon(
        widget.direction == 0 //아래
            ? Icons.arrow_downward
            : widget.direction == 1 //오른쪽
                ? Icons.arrow_forward
                : widget.direction == 2 //위
                    ? Icons.arrow_upward
                    : Icons.arrow_back,
        size: 40.0,
        color: Colors.blue,
      ),
    );
  }
}
