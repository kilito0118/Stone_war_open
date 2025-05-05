import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stone_war/home_screen.dart';
import 'package:stone_war/login/login_page.dart';
import 'package:stone_war/login/nickname_field.dart';
import 'package:stone_war/login/password_field.dart';
import 'package:stone_war/login/random_generate.dart';
import 'package:flutter/foundation.dart';
import 'package:stone_war/login/verify_nickname.dart';

import 'package:stone_war/login/regist_users.dart';

/*회원가입 페이지에서 할 남은 것들
1. 비번 확인이랑 같은지 검증
2. 닉네임 중복되는지 확인해주기
3. 실제로 회원가입이 되는지(유저 정보를 남길 수 있는지)
*/

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  TextEditingController nicknameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordCheckController = TextEditingController();

  Future<bool> signUp(
    String email,
    String nickName,
    String password,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      userCredential.user?.sendEmailVerification();
      registUsers(nickName, userCredential);

      return true;
    } on FirebaseAuthException catch (e) {
      String message = '알 수 없는 오류입니다.';
      message = e.code;
      switch (message) {
        case "missing-email":
          message = "이메일을 작성해주세요.";
          break;
        case "invalid-email":
          message = "이메일을 확인해주세요.";
          break;
        case "missing-passowrd":
          message = "비밀번호를 작성해주세요.";
          break;
        case "weak-password":
          message = "비밀번호를 더 강하게 작성해주세요.";
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알 수 없는 오류입니다.')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    //final FocusNode nickNameFocus = FocusNode();
    final FocusNode emailFocus = FocusNode();
    final FocusNode passwordFocus = FocusNode();
    final FocusNode passwordCheckFocus = FocusNode();
    final FocusNode buttonFocus = FocusNode();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double belowWidth = (kIsWeb) ? 520 : screenWidth - 30;
    return Scaffold(
      backgroundColor: const Color(0xFFD9BBA0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.08,
            left: ((screenWidth - belowWidth) / 2) > 0
                ? ((screenWidth - belowWidth) / 2)
                : 0,
            right: ((screenWidth - belowWidth) / 2) > 0
                ? ((screenWidth - belowWidth) / 2)
                : 0,
            bottom: 80,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: belowWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('회원가입'),
                SizedBox(height: 20),
                NicknameField(
                  controller: nicknameController,
                  nextfocus: emailFocus,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RandomGenerate(controller: nicknameController),
                    VerifyNickname(controller: nicknameController),
                  ],
                ),
                SizedBox(height: 20),
                AutofillGroup(
                  child: TextFormField(
                    focusNode: emailFocus,
                    textInputAction: TextInputAction.next, // 다음 필드로 이동
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(passwordFocus),
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    style: TextStyle(
                      fontSize: 25,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'or_not_official@naver.com',
                      hintStyle:
                          Theme.of(context).textTheme.displayLarge!.copyWith(
                                color: Color(0x3f131420),
                                fontSize: 25,
                              ),
                      labelText: "(아이디)이메일",
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
                  ),
                ),
                SizedBox(height: 20),
                Passwordfield(
                    focusNode: passwordFocus,
                    controller: passwordController,
                    emailcontroller: passwordController,
                    isLoginPage: false,
                    nextFocusNode: passwordCheckFocus),
                SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: TextFormField(
                    focusNode: passwordCheckFocus,
                    textInputAction: TextInputAction.next, // 다음 필드로 이동
                    onFieldSubmitted: (value) async {
                      bool isValid =
                          await isNicknameAvailable(nicknameController.text);
                      if (nicknameController.text.isEmpty || !isValid) {
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('닉네임을 확인하고 다시 시도해주세요.')),
                          );
                        }
                      } else if (passwordCheckController.text.isEmpty &&
                          passwordController.text.isEmpty &&
                          passwordController.text !=
                              passwordCheckController.text) {
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('비밀번호를 확인하고 다시 시도해주세요.')),
                          );
                        }
                      } else if (await signUp(
                        emailController.text,
                        nicknameController.text,
                        passwordController.text,
                      )) {
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (route) => false);
                        }
                      } else {
                        //print('왜이런다냐');
                      }
                    },

                    autovalidateMode: AutovalidateMode.always,
                    validator: (String? value) {
                      if (passwordController.text != value) {
                        return '비밀번호를 다시 확인해주세요.';
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 25),
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwordCheckController,
                    decoration: InputDecoration(
                      hintText: 'password',
                      hintStyle:
                          Theme.of(context).textTheme.displayLarge!.copyWith(
                                color: Color(0x3f131420),
                                fontSize: 25,
                              ),
                      labelText: "비밀번호 확인",
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
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  focusNode: buttonFocus,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey;
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.blue[200]!;
                        }
                        return Colors.transparent; // 기본
                      },
                    ),
                  ),
                  onPressed: () async {
                    bool isValid =
                        await isNicknameAvailable(nicknameController.text);
                    if (nicknameController.text.isEmpty || !isValid) {
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('닉네임을 확인하고 다시 시도해주세요.')),
                        );
                      }
                    } else if (passwordCheckController.text.isEmpty &&
                        passwordController.text.isEmpty &&
                        passwordController.text !=
                            passwordCheckController.text) {
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비밀번호를 확인하고 다시 시도해주세요.')),
                        );
                      }
                    } else if (await signUp(
                      emailController.text,
                      nicknameController.text,
                      passwordController.text,
                    )) {
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()),
                            (route) => false);
                      }
                    } else {
                      //print('왜이런다냐');
                    }
                  },
                  child: Text(
                    '회원가입 하기',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false);
                  },
                  child: Text(
                    '로그인 하러 가기',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
