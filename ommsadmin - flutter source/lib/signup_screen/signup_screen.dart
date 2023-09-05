import 'package:flutter/material.dart';
import 'package:three_youth_app/base/spinkit.dart';
import 'package:three_youth_app/signup_screen/signup_screen_1.dart';
import 'package:three_youth_app/signup_screen/signup_screen_1a.dart';
import 'package:three_youth_app/signup_screen/signup_screen_2.dart';
import 'package:three_youth_app/signup_screen/signup_screen_3.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = true;
  // ignore: unused_field
  late final double _screenHeight;
  // ignore: unused_field
  late final double _screenWidth;
  final PageController pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        _screenWidth = MediaQuery.of(context).size.width;
        _screenHeight = MediaQuery.of(context).size.height;
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('종료 확인'),
            content: new Text('앱을 종료 하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('종료'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: isLoading
          ? spinkit
          : PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SignupScreen1(
                  pageController: pageController,
                ),
                SignupScreen1a(
                  pageController: pageController,
                ),
                SignupScreen2(
                  pageController: pageController,
                ),
                SignupScreen3(
                  pageController: pageController,
                ),
              ],
            ),
    );
  }
}
