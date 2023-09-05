import 'dart:convert';
import 'dart:developer';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:three_youth_app/base/spinkit.dart';
import 'package:three_youth_app/signup_screen/signup_screen.dart';
import 'package:three_youth_app/utils/color.dart';
import 'package:three_youth_app/utils/toast.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import '../base/back_app_bar.dart';
import '../base/base_app_bar.dart';
import '../base/simple_dialog.dart';
import '../base/uiBase.dart';
import '../php/classCubeAPI.dart';

const List<String> list = <String>[
  '남자',
  '여자',
];

const List<String> _action_list = [
  "없음",
  "서비스/프로세스재시작",
  "시스템Reboot",
  "시스템Shutdown"
];

enum RamKind { Usage, UsedSize }

class MonitoringScreen extends StatefulWidget {
  MonitoringScreen({
    Key? key,
  }) : super(key: key);

  String idx = ""; //정책ID

  @override
  _MonitoringScreenState createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  bool isLoading = true;
  // ignore: unused_field
  late final double _screenHeight;
  // ignore: unused_field
  late final double _screenWidth;

  String userid = "";
  bool isPolicyUse = false;

  PageController pageMenu = PageController();

  final ScrollController scrollController = ScrollController();

  bool _isEmailForm = false;
  bool _isPasswordForm = false;
  bool _isSubmitButtonEnabled = false;

  bool isChecked = false;

  late TRow drPol;
  TDataSet dsRows = TDataSet();
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
      taskReload = doReload();
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: taskReload,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        } else {
          if (dsRows.getRowCount() == 0) {
            return Column(
              children: const [
                SizedBox(
                  height: 20,
                ),
                Text(
                  '내용이 없습니다.',
                  style: TextStyle(
                      color: ColorAssets.fontDarkGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          } else {
            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              itemCount: dsRows.getRowCount(),
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return getViewItem(index);
              },
            );
          }
        }
      },
    );
  }

  Widget uiField() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 30 + 5,
            child: uiText4("사용", cFont: Colors.black87),
          ),
          SizedBox(
            width: 200 + 10,
            child: uiText4("PC 정보", cFont: Colors.black87),
          ),
          SizedBox(
            width: 60 + 5 + 200 + 10,
            child: uiText4("정책 및 상태", cFont: Colors.black87),
          ),
          SizedBox(
            width: 70 + 5 + 80 + 10,
            child: uiText4("Agent 상태", cFont: Colors.black87),
          ),
          SizedBox(
            width: (60 + 5 + 60 + 5) * 3,
            child: uiText4("세 부 상 태", cFont: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget uiLabelRoundButton(
      String txt, {
        Color cBack = Colors.white,
        Color cFont = ColorAssets.fontMedGrey,
        bool isBold = false,
        TextAlign txtAlign = TextAlign.center,
        double size = 12,
        double width = 200,
        double height = 24,
        double padding = 5,
        IconData icon = Icons.info_outline,
        VoidCallback? func,
      }) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: cBack,
        ),
        onPressed: () {
          func!();
        },
        icon: Icon(
          icon,
          size: size,
        ),
        label: uiText4(txt, size: size, cFont: Colors.white), //label text
      ),
    );
  }
  Widget uiLabelRoundButtonWithCmd(
      String txt, {
        TRow? dr,
        String cmd = "",
        Color cBack = Colors.white,
        Color cFont = ColorAssets.fontMedGrey,
        bool isBold = false,
        TextAlign txtAlign = TextAlign.center,
        double size = 12,
        double width = 200,
        double height = 24,
        double padding = 5,
        IconData icon = Icons.info_outline,
        final Function? func,
      }) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: cBack,
        ),
        onPressed: () async {
          if (cmd == "PC명칭")
            {
              doInputDialog("PC 관리 명칭을 입력하세요.", dr!.value(cmd), context, () async {
                String sv = getEdit("doInputDialog")!.text;
                String sql = "update 모니터링_현황 ";
                sql += " set PC명칭 = '${sv}' ";
                sql += " where idx = '${dr!.value("idx")}' ";

                TCubeAPI ca = TCubeAPI();
                await ca.sqlExecPost(sql);
                showToast("PC명칭을 저장하였습니다.");
              });
            }
        },
        icon: Icon(
          icon,
          size: size,
        ),
        label: uiText4(txt, size: size, cFont: Colors.white), //label text
      ),
    );
  }

  Widget uiLabelRoundBox(
    String txt, {
    Color cBack = Colors.white,
    Color cFont = ColorAssets.fontMedGrey,
    bool isBold = false,
    TextAlign txtAlign = TextAlign.center,
    double size = 12,
    double width = 200,
    double height = 24,
    double padding = 5,
        IconData icon = Icons.info_outline,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cBack,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(
          color: ColorAssets.borderGrey,
          width: 1,
        ),
      ),
      width: width,
      height: height,
      padding: EdgeInsets.only(right: padding, left: padding),
      child: Center(
        child: uiText4(txt,
            cFont: cFont, txtAlign: txtAlign, isBold: isBold, size: size),
      ),
    );
  }

  // 1111111111111111111111111
  Widget getViewItem(int index) {
    TRow dr = dsRows.rows[index];

    String polidx = widget.idx;

    String sidx = dr.value("idx");
    String suse = dicKeyValue["${sidx}.사용"]!;

    return Container(
      height: 100,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.all(
      //     Radius.circular(10),
      //   ),
      //   border: Border.all(
      //     color: ColorAssets.borderGrey,
      //     width: 1,
      //   ),
      // ),
      padding: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Divider(),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 30,
                        child: Checkbox(
                          activeColor: Colors.blue,
                          value: dicKeyValue["${sidx}.사용"]! == "1",
                          onChanged: (value) {
                            setState(() {
                              if (dicKeyValue["${sidx}.사용"]! == "1")
                                dicKeyValue["${sidx}.사용"] = "0";
                              else
                                dicKeyValue["${sidx}.사용"] = "1";
                            });
                          },
                        ),
                      ),
                      uiLabelRoundButton(
                        dr.value("PC명칭"),
                        cFont: Colors.white,
                        cBack: Colors.blue,
                        width: 200,
                        height: 20,
                        size: 12,
                        func: () async {
                          doInputDialog("PC 관리 명칭을 입력하세요.", dr.value("PC명칭"), context, () async {
                            String sv = getEdit("doInputDialog")!.text;
                            String sql = "update 모니터링_현황 ";
                            sql += " set PC명칭 = '${sv}' ";
                            sql += " where idx = '${sidx}' ";

                            TCubeAPI ca = TCubeAPI();
                            await ca.sqlExecPost(sql);
                            showToast("PC명칭을 설정 하였습니다.");

                            setState(() {
                              taskReload = doReload();
                            });

                            Navigator.of(context).pop(false);
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 30),
                      uiLabelRoundBox(
                        "Name",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      uiText4(
                        dr.value("PCName"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      SizedBox(width: 30),
                      uiLabelRoundBox(
                        "IP",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      uiText4(
                        dr.value("PCIP"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "정책",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      uiLabelRoundButton(
                        dr.value("모니터링정책"),
                        cFont: Colors.white,
                        cBack: Colors.blue,
                        width: 200,
                        height: 20,
                        size: 12,
                        func: () async {
                          doPolicyDialog(
                              _screenWidth * 0.8,
                              _screenHeight * 0.8,
                              context, (TRow drParam) async {

                            String sql = "update 모니터링_현황 ";
                            sql += " set 모니터링정책ID = '${drParam.value("idx")}' ";
                            sql += " ,   모니터링정책 = '${drParam.value("정책명")}' ";
                            sql += " where idx = '${sidx}' ";

                            TCubeAPI ca = TCubeAPI();
                            await ca.sqlExecPost(sql);
                            showToast("정책을 설정 하였습니다.");

                            setState(() {
                              taskReload = doReload();
                            });

                            Navigator.of(context).pop(false);
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "상태",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 200,
                        child: uiText4(
                          dr.value("상태"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      uiLabelRoundBox(
                        "변경시각",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 200,
                        child: uiText4(
                          dr.value("변경시각"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "Agent 상태",
                        width: 70,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 80,
                        child: uiText4(
                          dr.value("agent상태"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "Agent 버전",
                        width: 70,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 80,
                        child: uiText4(
                          dr.value("agent버전"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 20,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                          ),
                          onPressed: () {},
                          icon: Icon(
                            Icons.play_arrow,
                            size: 14,
                          ),
                          label: uiText4("RUN",
                              size: 10, cFont: Colors.white), //label text
                        ),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 80,
                        height: 20,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.redAccent, // Background color
                          ),
                          onPressed: () {},
                          icon: Icon(
                            Icons.lock_reset,
                            size: 14,
                          ),
                          label: uiText4("RESET",
                              size: 10, cFont: Colors.white), //label text
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "CPU(%)",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("CPU"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "RAM(%)",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("메모리"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      uiLabelRoundBox(
                        "RAM(MB)",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("메모리사용량"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "서비스",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("서비스"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "스크립트",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("스크립트"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      uiLabelRoundBox(
                        "디렉토리",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: uiText4(
                          dr.value("디렉토리"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiLabelRoundBox(
                        "포트",
                        width: 60,
                        height: 20,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 30,
                        child: uiText4(
                          dr.value("포트"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5 + 20 + 5 + 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> doReload() async {
    bool isOK = false;

    try {
      SharedPreferences pref;
      pref = await SharedPreferences.getInstance();

      prefSetting = pref;

      String sql = "select * from 모니터링_현황 "; //where 정책ID = '${widget.idx}'";

      TCubeAPI ca = TCubeAPI();
      await dsRows.getDataSet(sql);

      if (dsRows.getRowCount() > 0) {
        for (int rr = 0; rr < dsRows.getRowCount(); rr++) {
          drPol = dsRows.rows[rr];

          String idx = drPol.value("idx");

          dicKeyValue["${idx}.사용"] = drPol.value("사용");
          // dicKeyValue["${idx}.이상대응방법"] = drPol.value("이상대응방법");
          //
          // if (dicKeyValue["${idx}.이상대응방법"]! == "") {
          //   dicKeyValue["${idx}.이상대응방법"] = "없음";
          // }
          //
          // getEdit("${idx}.서비스명")!.text = drPol.value("서비스명");
          // getEdit("${idx}.프로세스명")!.text = drPol.value("프로세스명");
          // getEdit("${idx}.감지시간")!.text = drPol.value("감지시간");
          // getEdit("${idx}.반복횟수")!.text = drPol.value("반복횟수");
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

  Widget uiComboAgentPolicy(String key, {List<String>? values}) {
    if (values!.length > 0) {
      dicComboItems[key] = values;
    }

    return Container(
      height: 40,
      child: DropdownButton<String>(
        value: dicKeyValue[key]!,
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

  Widget uiToolbar() {
    return Container(
      height: 30,
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              String polidx = widget.idx;

              Map<String, String> dic = Map();
              dic["정책ID"] = "'${polidx}'";

              TCubeAPI ca = TCubeAPI();
              await ca.dicToTable(
                "모니터링설정_서비스",
                dic,
              );

              setState(() {
                taskReload = doReload();
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.add_circle,
                  color: ColorAssets.fontDarkGrey,
                ),
                SizedBox(
                  width: 5,
                ),
                uiText3("추가", cFont: Colors.black45),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int getDataCount() {
    int cc = dsRows.rows.length;
    return cc;
  }

  Widget uiTableViewer() {
    return Container(
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
                if (isDataReady == false || getDataCount() == 0) {
                  return spinkit;
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // uiToolbar(),
                      uiField(),
                      Expanded(
                        child: getMainListViewUI(),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }

  Widget uiToolBox() {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(child: SizedBox()),
          TextButton(
            onPressed: () {
              setState(() {
                taskReload = doReload();
              });
            },
            child: Text(
              "새로고침",
              style: TextStyle(fontSize: 12.0),
              textScaleFactor: 1.0,
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20, top: 20),
      child: Column(
        children: [
          uiToolBox(),
          Expanded(
            child: uiTableViewer(),
          ),
        ],
      ),
    );
  }
}
