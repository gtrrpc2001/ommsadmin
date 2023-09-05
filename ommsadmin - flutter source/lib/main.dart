import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_youth_app/omms/MonitoringScreen.dart';
import 'package:three_youth_app/omms/monitorprocess_setting_screen.dart';
import 'package:three_youth_app/php/classCubeAPI.dart';
import 'package:three_youth_app/signup_screen/signup_screen.dart';
import 'package:three_youth_app/utils/current_user.dart';

import 'login_screen/devicelogin_screen.dart';
import 'login_screen/findpwd_screen.dart';
import 'login_screen/login_screen.dart';
import 'omms/main_screen.dart';
import 'php/classCubeTableViewer.dart';
import 'php/classCubeTableViewerScreen.dart';

late final SharedPreferences prefsmain;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefsmain = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: CurrentUser()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OMMS Administrator',

        //initialRoute: _auth.currentUser != null ? '/overview' : '/login',
        // initialRoute: prefsmain.getBool('isLogin') ?? false ? '/main' : '/login',
        initialRoute: '/main',
        routes:
        {
          '/login': (context) => const LoginScreen(),

          '/main': (context) => MainScreen(),

          '/monitoring': (context) => MonitoringScreen(),

          '/monitorpolicylist': (context) => CubeTableViewerScreenStatefulWidget(
            table: "모니터링정책_목록",
            sql: "",
            cellHeight: 24,
            fontSize: 12,
            iIdxStyle: 0,
            isEditable: true,
            isSelectable: false,
            onSelectRow: (TRow drParam) {},
          ),

          // '/test': (context) => MonitorProcessSettingScreen(idx: '8',
          // ),

          '/signup': (context) => const SignupScreen(),
          '/findpwd': (context) => const FindPwd(),
        },
        // theme: ThemeData(fontFamily: 'NotoSansCJKkr'),
        theme: ThemeData(),
      ),
    );
  }
}
