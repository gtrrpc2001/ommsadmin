import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_youth_app/base/base_app_bar.dart';
import 'package:three_youth_app/base/spinkit.dart';
import 'package:three_youth_app/signup_screen/signup_screen.dart';
import 'package:three_youth_app/utils/color.dart';
import 'package:three_youth_app/utils/toast.dart';

import '../php/classCubeAPI.dart';
import 'findpwd_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = true;
  // ignore: unused_field
  late final double _screenHeight;
  // ignore: unused_field
  late final double _screenWidth;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormFieldState> _emailFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordFormKey =
      GlobalKey<FormFieldState>();
  bool _isEmailForm = false;
  bool _isPasswordForm = false;
  bool _isSubmitButtonEnabled = false;

  bool isChecked = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Comfirm Exit'),
            content: new Text('Do you want exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('OK'),
              ),
            ],
          ),
        )) ??
        false;
  }

  AppBar uiAppBar()
  {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      backgroundColor: Color(0xff212332),

      flexibleSpace: new Container(
        decoration: BoxDecoration(
          color: Color(0xff212332),
        ),
      ),

      title: Container(
        child: InkWell(
          onTap: () {
            //Navigator.pushNamedAndRemoveUntil(context, '/overview', (route) => false);
          },
          child: Row(
            children: [
              // Image.asset(
              //   'assets/icons/icon_gpstracking.png',
              //   fit: BoxFit.fitHeight,
              // ),

              Text("OMMS Administrator"),

              SizedBox(width: 10,),

              Text("Remote Total Administrator Solution",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                ),
              ),

              Expanded(child:SizedBox(),),

              // Align(alignment: Alignment.centerRight,child:
              // ProfileCard()),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: uiAppBar(),
          //drawer: ,
          body: SingleChildScrollView(
            child: isLoading
                ? spinkit
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Color(0xff313d53),
                                fontWeight: FontWeight.w900,
                                fontSize: 18.0),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Welcome OMMS Administrator',
                            style: TextStyle(
                                color: Color(0xff8f95a0), fontSize: 14.0),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Check your id or password.',
                            style: TextStyle(
                                color: Color(0xff8f95a0), fontSize: 14.0),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        emailTextFormField(),
                        const SizedBox(
                          height: 10,
                        ),
                        passwordTextFormField(),
                        Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: isChecked,
                              shape: CircleBorder(),
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            Text(
                              'Auto Login',
                              // maxLines: 1,
                              // overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: ColorAssets.fontDarkGrey,
                                  fontSize: 12.0),
                            ),
                            Expanded(
                              child: InkWell(
                                child: Text(
                                  'Find ID/Password',
                                  // maxLines: 1,
                                  // overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        uiBtnLogin(_emailController.text,
                            _passwordController.text, _isSubmitButtonEnabled),

                        SizedBox(height: 40),
                        // Text(
                        //   'LOOKHEART 이용이 처음이신가요?',
                        //   style: TextStyle(
                        //       color: Color(0xff8f95a0), fontSize: 14.0),
                        // ),

                        // SizedBox(height: 20),
                        // uiBtnSignup(),
                        //FindPasswordButton(context),
                        //const SignUpButton(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  SizedBox emailTextFormField() {
    return SizedBox(
      width: _screenWidth * 0.8,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ID',
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8), fontSize: 12.0),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: _screenWidth * 0.8,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              // border: Border.all(
              //   color: ColorAssets.borderGrey,
              //   width: 1,
              // ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                  ),
                ),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                suffixIconConstraints: BoxConstraints(maxHeight: 20),
                border: InputBorder.none,
                // labelText: '아이디 입력',
                labelStyle: TextStyle(
                  color: ColorAssets.fontDarkGrey,
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                ),
                hintText: 'Input your ID',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontDarkGrey),
              ),
              controller: _emailController,
              textInputAction: TextInputAction.next,
              key: _emailFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {
                  _isEmailForm = _emailFormKey.currentState!.validate();
                  _isSubmitButtonEnabled = _isFormValid();
                });
              },
              // validator: (value) {
              //   //!Error: Pattern pattern => String pattern;
              //   String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              //   RegExp regex = RegExp(pattern);
              //   return (regex.hasMatch(value!)) ? null : '이메일 형식으로 입력해주세요';
              // },
            ),
          ),
        ],
      ),
    );
  }

  SizedBox passwordTextFormField() {
    return SizedBox(
      width: _screenWidth * 0.8,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(color: ColorAssets.fontDarkGrey, fontSize: 12.0),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: _screenWidth * 0.8,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              // border: Border.all(
              //   color: ColorAssets.borderGrey,
              //   width: 1,
              // ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
                suffixIcon: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                  ),
                ),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                suffixIconConstraints: BoxConstraints(maxHeight: 20),
                border: InputBorder.none,
                // labelText: '아이디 입력',
                labelStyle: TextStyle(
                  color: ColorAssets.fontDarkGrey,
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                ),
                hintText: 'Input your password',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontDarkGrey),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              controller: _passwordController,
              key: _passwordFormKey,
              onChanged: (value) {
                setState(() {
                  _isPasswordForm = _passwordFormKey.currentState!.validate();
                  _isSubmitButtonEnabled = _isFormValid();
                });
              },
              // validator: (value) {
              //   //!Error: Pattern pattern => String pattern;
              //   String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              //   RegExp regex = RegExp(pattern);
              //   return (regex.hasMatch(value!)) ? null : '이메일 형식으로 입력해주세요';
              // },
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormValid() {
    return ((_emailFormKey.currentState!.isValid &&
        _passwordFormKey.currentState!.isValid));
  }

  Widget uiBtnLogin(String id, String pwd, bool isEnabled) {
    return Container(
      height: 40,
      width: _screenWidth * 0.8,
      decoration: BoxDecoration(
        color: Color(0xff334771),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        // border: Border.all(
        //   color: ColorAssets.borderGrey,
        //   width: 1,
        // ),
      ),
      child: InkWell(
        child: Center(
          child: Text(
            'Login',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14.0),
          ),
        ),
        onTap: () async {
          if (isEnabled) {
            String sql =
                "SELECT * FROM 인원_목록 WHERE 아이디='$id' and 패스워드 = '$pwd' ";
            //String sql = 'SELECT * FROM login_info';
            //String sql = "INSERT INTO login_info (아이디, 패스워드, 신장, 몸무게, 성별, 생년월일, 이메일 ) VALUES ('bbb@gmail.com', '1234', '180cm', '100kg', '여', '001225', 'bbb@gmail.com')";\
            String result = '';
            int ir = 0;
            TDataSet ds = TDataSet();
            try {
              await ds.getDataSet(sql);
              ir = ds.rows.length;
            } on FormatException catch (e) {
              log(e.toString());
              showToast('Login Error');
            }

            if (ir == 0) {
              showToast('Not registerd id.');
            }
            if (ir > 0)
            {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if(isEnabled)
              {
                await prefs.setBool('isLogin', true);
                await prefs.setString('id', id);
                await prefs.setString('empid', id);
              }
              else
              {
                await prefs.setBool('isLogin', false);
                await prefs.setString('id', "");
                await prefs.setString('empid', "");
              }

              // await prefs.setString('empname', mapResult['result'][0]['8']);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/monitorpolicylist', (route) => false);
            } else {
              showToast('Incorect password.');
            }
          } else {
            showToast('Please input id and password.');
          }
        },
      ),
    );
  }

  Widget uiBtnSignup() {
    return Container(
      height: 40,
      width: _screenWidth * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: ColorAssets.borderGrey,
          width: 1,
        ),
      ),
      child: InkWell(
        child: Center(
          child: Text(
            'Register',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w900,
                fontSize: 14.0),
          ),
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupScreen()),
          );
        },
      ),
    );
  }
}

