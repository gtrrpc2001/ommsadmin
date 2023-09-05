import 'dart:convert';
import 'dart:developer';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:three_youth_app/base/spinkit.dart';
import 'package:three_youth_app/omms/monitorresponse_setting_screen.dart';
import 'package:three_youth_app/signup_screen/signup_screen.dart';
import 'package:three_youth_app/utils/color.dart';
import 'package:three_youth_app/utils/toast.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import '../base/back_app_bar.dart';
import '../base/base_app_bar.dart';
import '../base/simple_dialog.dart';
import '../base/uiBase.dart';
import '../php/classCubeAPI.dart';
import 'monitoradv_setting_screen.dart';
import 'monitorprocess_setting_screen.dart';
import 'monitorscript_setting_screen.dart';

const List<String> list = <String>[
  '남자',
  '여자',
];

const List<String> _action_list = ["없음", "시스템Reboot", "시스템Shutdown"];

enum RamKind { Usage, UsedSize }

class AgentPolicyScreen extends StatefulWidget {
  const AgentPolicyScreen({
    Key? key,
    required this.idx,
  }) : super(key: key);

  final String idx;

  @override
  _AgentPolicyScreenState createState() => _AgentPolicyScreenState();
}

class _AgentPolicyScreenState extends State<AgentPolicyScreen> {
  bool isLoading = true;
  // ignore: unused_field
  late final double _screenHeight;
  // ignore: unused_field
  late final double _screenWidth;

  String userid = "";
  bool isPolicyUse = false;

  PageController pageMenu = PageController();

  final TextEditingController _edtNotifyArrDetectCnt = TextEditingController();
  final GlobalKey<FormFieldState> _edtNotifyArrDetectCntKey =
      GlobalKey<FormFieldState>();

  final TextEditingController _edtNotifyTel1 = TextEditingController();
  final GlobalKey<FormFieldState> _edtNotifyTel1Key =
      GlobalKey<FormFieldState>();

  final TextEditingController _edtNotifyTel2 = TextEditingController();
  final GlobalKey<FormFieldState> _edtNotifyTel2Key =
      GlobalKey<FormFieldState>();

  final TextEditingController _edtOBSID = TextEditingController();
  final GlobalKey<FormFieldState> _edtNameKey = GlobalKey<FormFieldState>();

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormFieldState> _emailFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormFieldState> _passwordFormKey =
      GlobalKey<FormFieldState>();

  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormFieldState> _phoneFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _birthController = TextEditingController();
  final GlobalKey<FormFieldState> _birthFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormFieldState> _ageFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _genderController = TextEditingController();
  final GlobalKey<FormFieldState> _genderFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _heightController = TextEditingController();
  final GlobalKey<FormFieldState> _heightFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _weightController = TextEditingController();
  final GlobalKey<FormFieldState> _weightFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _timeController = TextEditingController();
  final GlobalKey<FormFieldState> _timeFormKey = GlobalKey<FormFieldState>();

  final TextEditingController _time2Controller = TextEditingController();
  final GlobalKey<FormFieldState> _time2FormKey = GlobalKey<FormFieldState>();

  final TextEditingController _edtBPMTarget = TextEditingController();
  final GlobalKey<FormFieldState> _edtBPMTargetKey =
      GlobalKey<FormFieldState>();

  final TextEditingController _edtStepMax = TextEditingController();
  final GlobalKey<FormFieldState> _edtStepMaxKey = GlobalKey<FormFieldState>();

  final TextEditingController _edtDistanceMax = TextEditingController();
  final GlobalKey<FormFieldState> _edtDistanceMaxKey =
      GlobalKey<FormFieldState>();

  final TextEditingController _edtCalMax = TextEditingController();
  final GlobalKey<FormFieldState> _edtCalMaxKey = GlobalKey<FormFieldState>();

  final TextEditingController _edteCalMax = TextEditingController();
  final GlobalKey<FormFieldState> _edteCalMaxKey = GlobalKey<FormFieldState>();

  bool _isEmailForm = false;
  bool _isPasswordForm = false;
  bool _isSubmitButtonEnabled = false;

  bool isChecked = false;

  late TRow drPol;
  late TDataSet dsTagList;
  bool isDataReady = false;

  int iTabSelected = 0;

  int iGender = 1;
  int iAge = 0;

  String sGender = "남자";

  String empname = "";
  String empid = "";
  String empregdate = "";
  String empemail = "";

  Future<bool>? taskReload;

  late SharedPreferences prefSetting;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
      taskReload = doSettingLoad();
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

  Future<bool> doSettingLoad() async {
    bool isOK = false;

    try {
      SharedPreferences pref;
      pref = await SharedPreferences.getInstance();

      prefSetting = pref;

      String sql = "select * from 모니터링정책_목록 where idx = '${widget.idx}' ";

      TCubeAPI ca = TCubeAPI();
      TDataSet ds = TDataSet();
      await ds.getDataSet(sql);

      if (ds.getRowCount() > 0) {
        drPol = ds.rows[0];

        String polidx = drPol.value("idx");

        getEdit("정책명")!.text = drPol.value("정책명");
        getEdit("정책설명")!.text = drPol.value("정책설명");

        isPolicyUse = drPol.value("사용") == "1" ? true : false;

        {
          int ichk = await ca.sqlToInt("select count(*) from 모니터링설정_cpu where 정책id = '${polidx}'");
          if (ichk == 0)
            {
              Map<String, String> dic = Map();
              dic["정책ID"] = "0";
              await ca.dicToTable("모니터링설정_cpu", dic);
            }
        }
        {
          String sql2 = "select * from 모니터링설정_cpu where 정책id = '${polidx}'";
          TDataSet ds2 = TDataSet();
          await ds2.getDataSet(sql2);
          if (ds2.getRowCount() > 0) {
            TRow dr = ds2.rows[0];
            getEdit("CPU사용율")!.text = dr.value("사용율");
            getEdit("CPU감지시간")!.text = dr.value("감지시간");
            getEdit("CPU반복횟수")!.text = dr.value("반복횟수");
            String act = dr.value("이상대응방법");
            if (_action_list.indexOf(act) < 0) act = _action_list.first;
            dicKeyValue["CPU이상대응방법"] = act;
          }
        }
        {
          String sql2 = "select * from 모니터링설정_메모리 where 정책id = '${polidx}'";
          TDataSet ds2 = TDataSet();
          await ds2.getDataSet(sql2);
          if (ds2.getRowCount() > 0) {
            TRow dr = ds2.rows[0];
            String sramkind = dr.value("종류");
            _RamKind = sramkind == "사용율" ? RamKind.Usage : RamKind.UsedSize;

            getEdit("메모리사용율")!.text = dr.value("사용율");
            getEdit("메모리사용량")!.text = dr.value("사용량");
            getEdit("메모리감지시간")!.text = dr.value("감지시간");
            getEdit("메모리반복횟수")!.text = dr.value("반복횟수");
          }
        }
      }

      isOK = true;
      isDataReady = true;
    } catch (E) {
      print(E);
      showToast(E.toString());
    }
    return isOK;
  }

  void doCheckDefault(TextEditingController cc, int vv) {
    int v = vv;
    try {
      v = int.parse(cc.text);
    } catch (E) {}
    cc.text = v.toString();
  }

  void doCheckDefaultDouble(TextEditingController cc, double vv) {
    double v = vv;
    try {
      v = double.parse(cc.text);
    } catch (E) {}
    cc.text = v.toString();
  }

  String drEmpRegDate() {
    String sRegDate = "";
    try {
      DateTime now = DateTime.parse(empregdate);
      var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
      sRegDate = formatter.format(now);
    } catch (E) {}
    return sRegDate;
  }

  Widget uiTop() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: Color(0xfff9fafb),
        // shape: BoxShape.rectangle,
        // borderRadius: BorderRadius.circular(8.0),
        border: Border(
          top: BorderSide(width: 1.0, color: ColorAssets.borderGrey),
          bottom: BorderSide(width: 1.0, color: ColorAssets.borderGrey),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            height: 40,
            child: Row(
              children: [
                Text(
                  userid,
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xff2b2b2b),
                    fontWeight: FontWeight.w900,
                  ),
                  textScaleFactor: 1.0,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "님",
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorAssets.fontLightGrey,
                  ),
                  textScaleFactor: 1.0,
                ),
                Expanded(child: SizedBox()),
                uiBtnLogOut(),
              ],
            ),
          ),
          Container(
            height: 24,
            child: Row(
              children: [
                Text(
                  "이메일",
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorAssets.fontLightGrey,
                  ),
                  textScaleFactor: 1.0,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  empemail,
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorAssets.fontDarkGrey,
                  ),
                  textScaleFactor: 1.0,
                ),
              ],
            ),
          ),
          Container(
            height: 24,
            child: Row(
              children: [
                Text(
                  "가입일",
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorAssets.fontLightGrey,
                  ),
                  textScaleFactor: 1.0,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  drEmpRegDate(),
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorAssets.fontDarkGrey,
                  ),
                  textScaleFactor: 1.0,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget uiTab(int no, String txt) {
    Color cFont = ColorAssets.fontMediumGrey;
    if (iTabSelected == no) {
      cFont = ColorAssets.fontDarkGrey;
    }

    if (iTabSelected == no) {
      return Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 2.0, color: Color(0xff313d53)),
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              iTabSelected = no;
              pageMenu.jumpToPage(no);
            });
          },
          child: Text(
            txt,
            style: TextStyle(
              fontSize: 12,
              color: cFont,
              fontWeight: FontWeight.w900,
            ),
            textScaleFactor: 1.0,
          ),
        ),
      );
    } else {
      return Container(
        height: 30,
        child: InkWell(
          onTap: () {
            setState(() {
              iTabSelected = no;
              pageMenu.jumpToPage(no);
            });
          },
          child: Text(
            txt,
            style: TextStyle(
              fontSize: 12,
              color: cFont,
              fontWeight: FontWeight.w900,
            ),
            textScaleFactor: 1.0,
          ),
        ),
      );
    }
  }

  Widget uiComboAgentPolicy(String key, {List<String>? values}) {
    if (values!.length > 0) {
      dicComboItems[key] = values;
    }

    return Container(
      height: 40,
      child: DropdownButton<String>(
        value: dicKeyValue[key],
        items:
            dicComboItems[key]!.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: uiText4(
              value,
            ),
          );
        }).toList(),
        // Step 5.
        onChanged: (String? newValue) {
          setState(() {
            dicKeyValue[key] = newValue!;
          });
        },
      ),
    );
  }

  Widget uiCPURAM() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),

          // ---------------------------------
          Align(
            child: uiText2("이상대응 설정",
                cFont: ColorAssets.fontDarkGrey, isBold: true),
            alignment: Alignment.centerLeft,
          ),
          Row(
            children: [
              uiComboAgentPolicy("CPU이상대응방법", values: _action_list),
              SizedBox(
                width: 10,
              ),
            ],
          ),

          SizedBox(
            height: 20,
          ),
          // ---------------------------------
          Align(
            child: uiText2("CPU 설정",
                cFont: ColorAssets.fontDarkGrey, isBold: true),
            alignment: Alignment.centerLeft,
          ),
          SizedBox(
            height: 10,
          ),

          Row(children: [
            uiEdt("사용율(%)", "CPU사용율", isTitle: true),
            SizedBox(
              width: 10,
            ),
            uiEdt("감지시간(초)", "CPU감지시간", isTitle: true),
            SizedBox(
              width: 10,
            ),
            uiEdt("반복횟수(회)", "CPU반복횟수", isTitle: true),
            SizedBox(
              width: 10,
            ),
          ]),

          SizedBox(
            height: 20,
          ),

          // ---------------------------------
          Align(
            child: uiText2("메모리 설정",
                cFont: ColorAssets.fontDarkGrey, isBold: true),
            alignment: Alignment.centerLeft,
          ),
          SizedBox(
            height: 10,
          ),

          Row(children: [
            SizedBox(
              width: 300,
              child: uiRamKind(),
            ),
            SizedBox(
              width: 10,
            ),
            uiEdt("감지시간(초)", "메모리감지시간", isTitle: true),
            SizedBox(
              width: 10,
            ),
            uiEdt("반복횟수(회)", "메모리반복횟수", isTitle: true),
            SizedBox(
              width: 10,
            ),
          ]),
        ],
      ),
    );
  }

  Widget uiProcess() {
    String polidx = drPol.value("idx");
    return MonitorProcessSettingScreen(idx: polidx);
  }

  Widget uiScript() {
    String polidx = drPol.value("idx");
    return MonitorScriptSettingScreen(idx: polidx);
  }

  Widget uiAdv() {
    String polidx = drPol.value("idx");
    return MonitorAdvSettingScreen(idx: polidx);
  }

  Widget uiNotify() {
    String polidx = drPol.value("idx");
    return MonitorResponseScreen(idx: polidx);
  }

  Widget getDateRangePicker() {
    return DateTimePicker(
      initialValue: '',
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      dateLabelText: 'Date',
      onChanged: (val) => print(val),
      validator: (val) {
        print(val);
        return null;
      },
      onSaved: (val) => print(val),
    );
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    _birthController.text = DateFormat('yy-MM-dd').format(args.value);

    SchedulerBinding.instance!.addPostFrameCallback((duration) {
      setState(() {});
    });
  }

  Widget uiEdtName() {
    return SizedBox(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '성명', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '성명을 입력하세요',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _edtOBSID,
              textInputAction: TextInputAction.next,
              key: _edtNameKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {},
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

  Widget uiEdtUpDown(
    String key,
    TextEditingController cc,
    Key kk,
    String sunit,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Color(0xffeff0f2),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      // padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: ColorAssets.fontLightGrey,
              ),
              onPressed: () async {
                try {
                  int vv = await prefSetting.getInt(key) ?? 0;
                  vv--;
                  cc.text = vv.toString();
                  await prefSetting.setInt(key, vv);
                } catch (E) {}
              },
            ),
          ),
          Expanded(
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
              ),
              controller: cc,
              textInputAction: TextInputAction.next,
              key: kk,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) async {
                int iv = int.parse(value) ?? 0;
                await prefSetting.setInt(key, iv);
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              sunit,
              style: const TextStyle(
                fontSize: 12,
                color: ColorAssets.fontLightGrey,
              ),
              textScaleFactor: 1.0,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: ColorAssets.fontLightGrey,
              ),
              onPressed: () async {
                try {
                  int vv = await prefSetting.getInt(key) ?? 0;
                  vv++;
                  cc.text = vv.toString();
                  await prefSetting.setInt(key, vv);
                } catch (E) {}
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget uiEdt(
  //   String key,
  //   TextEditingController cc,
  //   Key kk,
  // ) {
  //   return Container(
  //     height: 40,
  //     decoration: BoxDecoration(
  //       color: Color(0xffeff0f2),
  //       borderRadius: BorderRadius.all(
  //         Radius.circular(10),
  //       ),
  //     ),
  //     // padding: EdgeInsets.only(left: 10, right: 10),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: TextFormField(
  //             style: const TextStyle(
  //                 color: ColorAssets.fontDarkGrey, fontSize: 14),
  //             decoration: const InputDecoration(
  //               isDense: true,
  //               contentPadding:
  //                   EdgeInsets.symmetric(horizontal: 0, vertical: 5),
  //               suffixIconConstraints: BoxConstraints(maxHeight: 20),
  //               border: InputBorder.none,
  //               // labelText: '아이디 입력',
  //               labelStyle: TextStyle(
  //                 color: ColorAssets.fontDarkGrey,
  //                 fontSize: 12,
  //                 // fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //             controller: cc,
  //             textInputAction: TextInputAction.next,
  //             key: kk,
  //             textAlign: TextAlign.center,
  //             // keyboardType: TextInputType.emailAddress,
  //             onChanged: (value) async {
  //
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget uiEdtPhone() {
    return SizedBox(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '휴대폰 번호', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '010-1234-9650',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              key: _phoneFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {},
            ),
          ),
        ],
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "취소",
        textScaleFactor: 1.0,
      ),
      onPressed: () {},
    );
    Widget continueButton = TextButton(
      child: Text(
        "확인",
        textScaleFactor: 1.0,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "날짜 선택",
        textScaleFactor: 1.0,
      ),
      content: getDateRangePicker(),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void doAgeCalc() {
    DateTime dtBirthday = DateFormat('yyyy-MM-dd').parse(_birthController.text);

    DateTime dtNow = DateTime.now();
    String sNow = DateFormat('yyyy-MM-dd').format(dtNow);
    dtNow = DateFormat('yyyy-MM-dd').parse(sNow);
    iAge = dtNow.year - dtBirthday.year + 1;
    _ageController.text = iAge.toString();
   }

  Widget uiEdtBirth() {
    return SizedBox(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '생년월일', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: DateTimePicker(
                initialValue: _birthController.text,
                icon: Icon(
                  Icons.calendar_month,
                ),
                dateMask: 'yy-MM-dd',
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                onChanged: (val) {
                  try {
                    _birthController.text = val!;
                  } catch (E) {}
                  doAgeCalc();
                },
                validator: (val) {
                  //print(val);
                  return null;
                },
                onSaved: (val) {},
              ),
            ),
            // TextFormField(
            //   style: const TextStyle(
            //       color: ColorAssets.fontDarkGrey, fontSize: 14),
            //   decoration: InputDecoration(
            //     suffixIcon: Align(
            //       widthFactor: 1.0,
            //       heightFactor: 1.0,
            //       child: InkWell(
            //         onTap: () {
            //
            //           // showAlertDialog(context);
            //         },
            //         child: Icon(
            //           Icons.date_range,
            //           size: 18,
            //         ),
            //       ),
            //     ),
            //     isDense: true,
            //     contentPadding:
            //         EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            //     suffixIconConstraints: BoxConstraints(maxHeight: 20),
            //     border: InputBorder.none,
            //     // labelText: '아이디 입력',
            //     labelStyle: TextStyle(
            //       color: ColorAssets.fontDarkGrey,
            //       fontSize: 12,
            //       // fontWeight: FontWeight.bold,
            //     ),
            //     hintText: '2000년 01월 01일',
            //     hintStyle:
            //         TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
            //   ),
            //   controller: _birthController,
            //   textInputAction: TextInputAction.next,
            //   key: _birthFormKey,
            //   // keyboardType: TextInputType.emailAddress,
            //   onChanged: (value) {
            //     setState(() {});
            //   },
            // ),
          ),
        ],
      ),
    );
  }

  Widget uiEdtAge() {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '나이', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '20 세',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _ageController,
              textInputAction: TextInputAction.next,
              key: _ageFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget uiEdtGender() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '성별', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      iGender = 1;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          empid + ".empmale", iGender.toString());
                      setState(() {});
                    },
                    child: Text(
                      '남자',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          color: iGender == 1
                              ? ColorAssets.fontDarkGrey
                              : ColorAssets.fontLightGrey,
                          fontSize: 12,
                          fontWeight: iGender == 1
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () async {
                      iGender = 2;
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(
                          empid + ".empmale", iGender.toString());
                      setState(() {});
                    },
                    child: Text(
                      '여자',
                      textScaleFactor: 1.0,
                      style: TextStyle(
                          color: iGender == 2
                              ? ColorAssets.fontDarkGrey
                              : ColorAssets.fontLightGrey,
                          fontSize: 12,
                          fontWeight: iGender == 2
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                ),
              ],
            ),
            // DropdownButton<String>(
            //   value: sGender,
            //   // icon: const Icon(Icons.people),
            //   elevation: 16,
            //   style: TextStyle(color: ColorAssets.fontDarkGrey),
            //   underline: Container(
            //     height: 0,
            //   ),
            //   onChanged: (String? value) {
            //     // This is called when the user selects an item.
            //     setState(() async {
            //       SharedPreferences prefs = await SharedPreferences.getInstance();
            //       sGender = value!;
            //       prefs.setString(empid + ".empgender", sGender!);
            //     });
            //   },
            //   items: list.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),

            // TextFormField(
            //
            //
            //   style: const TextStyle(
            //       color: ColorAssets.fontDarkGrey, fontSize: 14),
            //   decoration: const InputDecoration(
            //     isDense: true,
            //     contentPadding:
            //         EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            //     suffixIconConstraints: BoxConstraints(maxHeight: 20),
            //     border: InputBorder.none,
            //     // labelText: '아이디 입력',
            //     labelStyle: TextStyle(
            //       color: ColorAssets.fontDarkGrey,
            //       fontSize: 12,
            //       // fontWeight: FontWeight.bold,
            //     ),
            //     hintText: '남성',
            //     hintStyle:
            //         TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
            //   ),
            //   controller: _genderController,
            //   textInputAction: TextInputAction.next,
            //   key: _genderFormKey,
            //   // keyboardType: TextInputType.emailAddress,
            //   onChanged: (value) {
            //     setState(() {});
            //   },
            // ),
          ),
        ],
      ),
    );
  }

  Widget uiEdtHeight() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '키', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '170 cm',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _heightController,
              textInputAction: TextInputAction.next,
              key: _heightFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget uiEdtWeight() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '체중', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '70 kg',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _weightController,
              textInputAction: TextInputAction.next,
              key: _weightFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget uiEdttime() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '수면시간', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '23',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _timeController,
              textInputAction: TextInputAction.next,
              key: _timeFormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget uiEdttime2() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '', textScaleFactor: 1.0,
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
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
            child: TextFormField(
              style: const TextStyle(
                  color: ColorAssets.fontDarkGrey, fontSize: 14),
              decoration: const InputDecoration(
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
                hintText: '7',
                hintStyle:
                    TextStyle(fontSize: 12, color: ColorAssets.fontLightGrey),
              ),
              controller: _time2Controller,
              textInputAction: TextInputAction.next,
              key: _time2FormKey,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
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
            '회원가입',
            textScaleFactor: 1.0,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: ColorAssets.fontLightGrey,
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

  Widget uiBtnLogOut() {
    return Container(
      height: 26,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(
          color: ColorAssets.borderGrey,
          width: 1,
        ),
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '로그아웃', textScaleFactor: 1.0,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: ColorAssets.fontLightGrey,
                  // fontWeight: FontWeight.w900,
                  fontSize: 10.0),
            ),
            SizedBox(
              width: 5,
            ),
            Icon(
              Icons.exit_to_app,
              color: ColorAssets.fontLightGrey,
              size: 14,
            ),
          ],
        ),
        onTap: () async {
          doSettingLoad();
          simpleDialog(context, '로그아웃', '로그아웃 하시겠습니까?', doLogout);
        },
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
              '비밀번호', textScaleFactor: 1.0,
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
                hintText: '비밀번호를 입력하세요',
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
            '로그인',
            textScaleFactor: 1.0,
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
              showToast('로그인 에러');
            }

            if (ir == 0) {
              showToast('가입되지 않은 아이디입니다.');
            }
            if (ir > 0) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (isEnabled) {
                await prefs.setBool('isLogin', true);
                await prefs.setString('id', id);
                await prefs.setString('empid', id);
              } else {
                await prefs.setBool('isLogin', false);
                await prefs.setString('id', "");
                await prefs.setString('empid', "");
              }

              // await prefs.setString('empname', mapResult['result'][0]['8']);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/ecg', (route) => false);
            } else {
              showToast('비밀번호가 맞지 않습니다.');
            }
          } else {
            showToast('아이디와 비밀번호를 올바르게 입력해주세요');
          }
        },
      ),
    );
  }

  Widget uiBtnSaveAPI() {
    return Container(
      height: 40,
      // width: _screenWidth * 0.8,
      margin: EdgeInsets.only(left: 20, right: 20),
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
            '저  장',
            textScaleFactor: 1.0,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14.0),
          ),
        ),
        onTap: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userid = await prefs.getString("id") ?? "";
          empid = _edtOBSID.text;
          await prefs.setString("empid", empid);

          String sql =
              "update 인원_목록 set 보호대상아이디 = '$empid' where 아이디 = '$userid' ";
          TCubeAPI ca = TCubeAPI();
          await ca.sqlExecPost(sql);

          showToast("저장 하였습니다.");
        },
      ),
    );
  }

  void doLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', false);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  bool isValue(String key) {
    if (prefSetting.containsKey(key) == false) return false;
    return prefSetting.getInt(key) == 1 ?? false;
  }

  Widget uiSwitch(String key, String son, String soff) {
    Color cFont = ColorAssets.fontLightGrey;

    return FutureBuilder<bool>(
      future: taskReload,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: Color(0xffeff0f2),
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    decoration: !isValue(key)
                        ? BoxDecoration(
                            color: Color(0xff334771),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          )
                        : BoxDecoration(),
                    child: InkWell(
                      child: Center(
                        child: Text(
                          soff,
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: !isValue(key) ? Colors.white : cFont,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0),
                        ),
                      ),
                      onTap: () async {
                        setState(() {
                          prefSetting.setInt(key, 0);
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 32,
                    margin: EdgeInsets.only(left: 20, right: 20),
                    decoration: isValue(key)
                        ? BoxDecoration(
                            color: Color(0xff334771),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          )
                        : BoxDecoration(),
                    child: InkWell(
                      child: Center(
                        child: Text(
                          son,
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: isValue(key) ? Colors.white : cFont,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.0),
                        ),
                      ),
                      onTap: () async {
                        setState(() {
                          prefSetting.setInt(key, 1);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  Widget uiTabControl() {
    return Container(
      height: 50,
      // padding: EdgeInsets.only(left: 20, right: 20),
      // decoration: BoxDecoration(
      //   color: Color(0xfff9fafb),
      //   // shape: BoxShape.rectangle,
      //   // borderRadius: BorderRadius.circular(8.0),
      //   border: Border(
      //     top: BorderSide(width: 1.0, color: ColorAssets.borderGrey),
      //     bottom: BorderSide(width: 1.0, color: ColorAssets.borderGrey),
      //   ),
      // ),
      child: Column(
        children: [
          Row(
            children: [
              uiTab(0, "CPU, 메모리 설정"),
              SizedBox(
                width: 10,
              ),
              uiTab(1, "서비스, 프로세스"),
              SizedBox(
                width: 10,
              ),
              uiTab(2, "스크립트"),
              SizedBox(
                width: 10,
              ),
              uiTab(3, "고급"),
              SizedBox(
                width: 10,
              ),
              uiTab(4, "알림 설정"),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  RamKind? _RamKind = RamKind.Usage;
  Widget uiRamKind() {
    return Column(
      children: <Widget>[
        ListTile(
          //ListTile - title에는 내용,
          //leading or trailing에 체크박스나 더보기와 같은 아이콘을 넣는다.
          title: uiText4('Usage(%)',
              cFont: ColorAssets.fontDarkGrey, isBold: true),
          leading: Radio<RamKind>(
            value: RamKind.Usage,
            groupValue: _RamKind,
            onChanged: (RamKind? value) {
              setState(() {
                _RamKind = value;
              });
            },
          ),
          dense: true,
          visualDensity: VisualDensity(vertical: 4), // to expand
          trailing: uiEdt("사용율(%)", "메모리사용율", isTitle: true),
        ),
        ListTile(
          title: uiText4('Used Size(MB)',
              cFont: ColorAssets.fontDarkGrey, isBold: true),
          leading: Radio<RamKind>(
            value: RamKind.UsedSize,
            groupValue: _RamKind,
            onChanged: (RamKind? value) {
              setState(() {
                _RamKind = value;
              });
            },
          ),
          dense: true,
          visualDensity: VisualDensity(vertical: 4), // to expand
          trailing: uiEdt("사용량(MB)", "메모리사용량", isTitle: true),
        ),
      ],
    );
  }

  Widget uiBtnPolicySave() {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: () async {
          TCubeAPI ca = TCubeAPI();

          String polidx = drPol.value("idx");

          String pol = drPol.value("정책명");
          String polnew = dicEdtCtrl["정책명"]!.text;

          {
            bool isExist = await ca.sqlToInt(
                    "select count(*) from 모니터링정책_목록 where 정책명 ='${polnew}'") >
                0;

            if (polnew != pol) {
              if (isExist) {
                Alert(
                  context: context,
                  type: AlertType.error,
                  title: "확인",
                  desc: "이미 존재하는 정책명 입니다.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "확인",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      width: 120,
                    )
                  ],
                ).show();
                return;
              }
            }

            Map<String, String> dic = Map();
            dic["사용"] = "${isPolicyUse ? "1" : "0"}";
            dic["정책명"] = "'${polnew}'";
            dic["정책설명"] = "'${dicEdtCtrl["정책설명"]!.text}'";
            dic["변경시각"] = "'${getDTToString()}'";

            await ca.dicToTable("모니터링정책_목록", dic,
                where: isExist ? " idx = ${polidx}" : "");
          }

          {
            bool isExist = await ca.sqlToInt(
                    "select count(*) from 모니터링설정_cpu where 정책ID ='${polidx}'") >
                0;
            Map<String, String> dic = Map();
            dic["정책ID"] = "'${polidx}'";
            dic["정책명"] = "'${polnew}'";
            dic["사용율"] = "${dicEdtCtrl["CPU사용율"]!.text}";
            dic["감지시간"] = "${dicEdtCtrl["CPU감지시간"]!.text}";
            dic["반복횟수"] = "${dicEdtCtrl["CPU반복횟수"]!.text}";
            dic["이상대응방법"] = "'${dicKeyValue["CPU이상대응방법"]}'";

            await ca.dicToTable("모니터링설정_cpu", dic,
                where: isExist ? " 정책ID = ${polidx}" : "");
          }

          {
            bool isExist = await ca.sqlToInt(
                    "select count(*) from 모니터링설정_메모리 where 정책ID ='${polidx}'") >
                0;
            Map<String, String> dic = Map();
            dic["정책ID"] = "'${polidx}'";
            dic["정책명"] = "'${polnew}'";
            dic["종류"] = "'${_RamKind == RamKind.Usage ? "사용율" : "사용량"}'";
            dic["사용율"] = "${dicEdtCtrl["메모리사용율"]!.text}";
            dic["사용량"] = "${dicEdtCtrl["메모리사용량"]!.text}";
            dic["감지시간"] = "${dicEdtCtrl["메모리감지시간"]!.text}";
            dic["반복횟수"] = "${dicEdtCtrl["메모리반복횟수"]!.text}";
            dic["이상대응방법"] = "'${dicKeyValue["CPU이상대응방법"]}'"; // CPU로 공통 사용

            await ca.dicToTable("모니터링설정_메모리", dic,
                where: isExist ? " 정책ID = ${polidx}" : "");
          }

          showToast("저장 하였습니다.");
        },
        child: Text(
          "저장",
          style: TextStyle(fontSize: 12.0),
          textScaleFactor: 1.0,
        ),
      ),
    );
  }

  Future<void> doAppBarBack() async
  {
    setState(() {
      taskReload = doSettingLoad();
    });
  }

  // bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: uiAppBarPopup(context, "모니터링 정책 설정", doAppBarBack),
      body: Container(
        // width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          // shape: BoxShape.rectangle,
          // borderRadius: BorderRadius.circular(8.0),
        ),
        child: isLoading
            ? spinkit
            : FutureBuilder<bool>(
                future: taskReload,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (isDataReady == false) {
                    return SizedBox();
                  } else {
                    return Container(
                      // padding: EdgeInsets.only(left: 20, right: 20),
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     top: BorderSide(
                      //         width: 1.0, color: ColorAssets.borderGrey),
                      //   ),
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          Row(
                            children: [
                              uiText2("정책명",
                                  cFont: ColorAssets.fontDarkGrey,
                                  isBold: true),
                              Expanded(child: SizedBox()),
                              uiBtnPolicySave(),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              uiEdt("정책명", "정책명", width: 200),
                              SizedBox(
                                width: 10,
                              ),
                              Checkbox(
                                  value: isPolicyUse,
                                  onChanged: (value) {
                                    setState(() {
                                      isPolicyUse = value!;
                                    });
                                  }),
                              uiText4("사용",
                                  cFont: ColorAssets.fontDarkGrey,
                                  isBold: true),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          uiText2("정책설명",
                              cFont: ColorAssets.fontDarkGrey, isBold: true),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: uiEdt(
                                  "정책설명",
                                  "정책설명",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorAssets.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  color: ColorAssets.borderGrey,
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  uiTabControl(),
                                  Expanded(
                                    child: PageView(
                                      controller: pageMenu,
                                      children: [
                                        SingleChildScrollView(
                                          child: uiCPURAM(),
                                        ),
                                        SingleChildScrollView(
                                          child: uiProcess(),
                                        ),
                                        SingleChildScrollView(
                                          child: uiScript(),
                                        ),
                                        SingleChildScrollView(
                                          child: uiAdv(),
                                        ),
                                        SingleChildScrollView(
                                          child: uiNotify(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
