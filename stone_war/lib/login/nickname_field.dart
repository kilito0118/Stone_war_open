import 'package:flutter/material.dart';

class NicknameField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode nextfocus;
  const NicknameField({
    super.key,
    required this.nextfocus,
    required this.controller,
  });

  @override
  NicknameFieldState createState() => NicknameFieldState();
}

class NicknameFieldState extends State<NicknameField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validText = RegExp(r"^[ㄱ-ㅎ가-힣0-9a-zA-Z\s+]*$");

    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          return TextFormField(
            textInputAction: TextInputAction.next, // 다음 필드로 이동
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(widget.nextfocus),
            validator: (String? value) {
              if (value!.isEmpty || !validText.hasMatch(value)) {
                return '값은 채워야죠';
              }
              return null;
            },
            controller: widget.controller,
            onChanged: (value) {
              setState(() {});
            },
            maxLength: 24,
            style: TextStyle(fontSize: 25),
            decoration: InputDecoration(
              hintText: '세계최초의위대한석전플레이어이자개발자바악쥬녀기',
              hintStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
                    color: Color(0x3f131420),
                    fontSize: 25,
                  ),
              labelText: "닉네임",
              labelStyle: Theme.of(context).textTheme.bodySmall,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.zero),
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 4,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          );
        });
  }
}
