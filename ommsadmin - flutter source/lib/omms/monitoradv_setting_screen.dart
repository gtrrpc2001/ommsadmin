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

const List<String> _action_list = ["없음", "시스템Reboot", "시스템Shutdown"];
const List<String> _detect_list = ["존재함", "존재하지않음"];

enum RamKind { Usage, UsedSize }

class MonitorAdvSettingScreen extends StatefulWidget {
  const MonitorAdvSettingScreen({
    Key? key,
    required this.idx,
  }) : super(key: key);

  final String idx; //정책ID

  @override
  _MonitorAdvSettingScreenState createState() =>
      _MonitorAdvSettingScreenState();
}

class _MonitorAdvSettingScreenState
    extends State<MonitorAdvSettingScreen> {
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

  Widget uiField1() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 65 + 300 + 5 + 155 + 85 + 25,
            child: uiText4("디렉토리 감지", cFont: Colors.black45),
          ),
          SizedBox(
            width: 65 + 85 + 85,
            child: uiText4("포트 감지", cFont: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget uiField2() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 65,
            child: uiText4("사용", cFont: Colors.black45),
          ),
          SizedBox(
            width: 305,
            child: uiText4("경로", cFont: Colors.black45),
          ),
          SizedBox(
            width: 5,
          ),
          SizedBox(
            width: 155,
            child: uiText4("감지방법", cFont: Colors.black45),
          ),
          SizedBox(
            width: 85,
            child: uiText4("감지간격(초)", cFont: Colors.black45),
          ),
          ////////////////////////////////////////
          SizedBox(
            width: 25,
          ),
          SizedBox(
            width: 65,
            child: uiText4("사용", cFont: Colors.black45),
          ),
          SizedBox(
            width: 85,
            child: uiText4("포트번호", cFont: Colors.black45),
          ),
          SizedBox(
            width: 85,
            child: uiText4("감지간격(초)", cFont: Colors.black45),
          ),

          SizedBox(width: 155, child: uiText4("이상대응방법", cFont: Colors.black45),),

        ],
      ),
    );
  }

  // 1111111111111111111111111
  Widget getViewItem(int index) {
    TRow dr = dsRows.rows[index];

    String polidx = widget.idx;

    String sidx = dr.value("idx");
    if (dicKeyValue.containsKey("${sidx}.사용") == false)
      {
        dicKeyValue["${sidx}.사용"] = "0";
      }
    String suse = dicKeyValue["${sidx}.사용"]!;

    return Container(
      height: 60,
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
        children: [
          Divider(),
          // Expanded(child:
          Row(
            children: [
              SizedBox(
                width: 60,
                child: Checkbox(
                  activeColor: Colors.blue,
                  value: dicKeyValue["${sidx}.디렉토리감시"]! == "1",
                  onChanged: (value) {
                    setState(() {
                      if (dicKeyValue["${sidx}.디렉토리감시"]! == "1")
                        dicKeyValue["${sidx}.디렉토리감시"] = "0";
                      else
                        dicKeyValue["${sidx}.디렉토리감시"] = "1";
                    });
                  },
                ),
              ),
              SizedBox(
                width: 5,
              ),
              uiEdt(
                "경로",
                "${sidx}.디렉토리경로",
                width: 300,
              ),
              SizedBox(
                width: 5,
              ),

              SizedBox(
                width: 150,
                child: uiComboAgentPolicy(
                    "${sidx}.디렉토리감시방법", values: _detect_list
                ),
              ),
              SizedBox(
                width: 5,
              ),
              uiEdt(
                "감지간격(초)",
                "${sidx}.디렉토리감시간격",
                width: 80,
              ),
              SizedBox(
                width: 25,
              ),
              /////////////////////////////////////////////////
              SizedBox(
                width: 60,
                child: Checkbox(
                  activeColor: Colors.blue,
                  value: dicKeyValue["${sidx}.포트감시"]! == "1",
                  onChanged: (value) {
                    setState(() {
                      if (dicKeyValue["${sidx}.포트감시"]! == "1")
                        dicKeyValue["${sidx}.포트감시"] = "0";
                      else
                        dicKeyValue["${sidx}.포트감시"] = "1";
                    });
                  },
                ),
              ),
              SizedBox(
                width: 5,
              ),
              uiEdt(
                "포트번호",
                "${sidx}.포트번호",
                width: 80,
              ),
              SizedBox(
                width: 5,
              ),
              uiEdt(
                "감지간격(초)",
                "${sidx}.포트감지간격",
                width: 80,
              ),
              SizedBox(
                width: 5,
              ),


              SizedBox(width: 150,child:
              uiComboAgentPolicy("${sidx}.이상대응방법", values: _action_list),
              ),

              SizedBox(
                width: 5,
              ),

              ////////////////////////////////////////////////
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    TCubeAPI ca = TCubeAPI();

                    String spath = getEdit("${sidx}.디렉토리경로")!.text;
                    spath = base64.encode(utf8.encode(spath));

                    Map<String, String> dic = Map();
                    dic["디렉토리감시"] = dicKeyValue["${sidx}.디렉토리감시"]!;
                    dic["디렉토리경로"] = "'${spath}'";
                    dic["디렉토리감시방법"] = "'${dicKeyValue["${sidx}.디렉토리감시방법"]!}'";
                    dic["디렉토리감시간격"] = "${getEdit("${sidx}.디렉토리감시간격")!.text}";

                    dic["포트감시"] = dicKeyValue["${sidx}.포트감시"]!;
                    dic["포트번호"] = "${getEdit("${sidx}.포트번호")!.text}";
                    dic["포트감지간격"] = "${getEdit("${sidx}.포트감지간격")!.text}";

                    dic["이상대응방법"] = "'${dicKeyValue["${sidx}.이상대응방법"]}'";

                    await ca.dicToTable("모니터링설정_고급", dic,
                        where: " idx = ${sidx}");

                    showToast("저장 하였습니다.");
                  },
                  child: Text(
                    "저장",
                    style: TextStyle(fontSize: 12.0),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    TCubeAPI ca = TCubeAPI();

                    String sql = "delete from 모니터링설정_고급 where idx = ${sidx}";
                    ca.sqlExecPost(sql);

                    setState(() {
                      taskReload = doReload();
                    });

                    showToast("삭제 하였습니다.");
                  },
                  child: Text(
                    "삭제",
                    style: TextStyle(fontSize: 12.0),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
            ],
            // ),
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

      String sql = "select * from 모니터링설정_고급 where 정책ID = '${widget.idx}'";

      TCubeAPI ca = TCubeAPI();
      await dsRows.getDataSet(sql);

      if (dsRows.getRowCount() > 0) {
        for (int rr = 0; rr < dsRows.getRowCount(); rr++) {
          drPol = dsRows.rows[rr];

          String idx = drPol.value("idx");

          dicKeyValue["${idx}.이상대응방법"] = drPol.value("이상대응방법");
          if (dicKeyValue["${idx}.이상대응방법"]! == "") {
            dicKeyValue["${idx}.이상대응방법"] = "없음";
          }

          {
            dicKeyValue["${idx}.디렉토리감시"] = drPol.value("디렉토리감시");

            dicKeyValue["${idx}.디렉토리감시방법"] = drPol.value("디렉토리감시방법");
            if (dicKeyValue["${idx}.디렉토리감시방법"]! == "") {
              dicKeyValue["${idx}.디렉토리감시방법"] = "존재함";
            }

            String spath = drPol.value("디렉토리경로");
            List<int> decode = base64.decode(spath);
            spath = utf8.decode(decode);
            getEdit("${idx}.디렉토리경로")!.text = spath;

            getEdit("${idx}.디렉토리감시간격")!.text = drPol.value("디렉토리감시간격");
          }

          {
            dicKeyValue["${idx}.포트감시"] = drPol.value("포트감시");

            getEdit("${idx}.포트번호")!.text = drPol.value("포트번호");
            getEdit("${idx}.포트감지간격")!.text = drPol.value("포트감지간격");
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
                "모니터링설정_고급",
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 800,
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
                  return spinkit;
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      uiToolbar(),
                      uiField1(),
                      uiField2(),
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
}
