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

class MonitorResponseScreen extends StatefulWidget {
  const MonitorResponseScreen({
    Key? key,
    required this.idx,
  }) : super(key: key);

  final String idx; //정책ID

  @override
  _MonitorResponseScreenState createState() => _MonitorResponseScreenState();
}

class _MonitorResponseScreenState extends State<MonitorResponseScreen> {
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

  Widget uiField() {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 85,
            child: uiText4("사용", cFont: Colors.black45),
          ),
          SizedBox(
            width: 205,
            child: uiText4("수신자 이메일", cFont: Colors.black45),
          ),
        ],
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
              SizedBox(
                width: 5,
              ),
              uiEdt(
                "수신자이메일",
                "${sidx}.수신자이메일",
                width: 200,
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    TCubeAPI ca = TCubeAPI();

                    Map<String, String> dic = Map();
                    dic["사용"] = dicKeyValue["${sidx}.사용"]!;
                    dic["수신자이메일"] = "'${getEdit("${sidx}.수신자이메일")!.text}'";
                    
                    await ca.dicToTable("이상대응설정_메일", dic,
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

                    String sql = "delete from 이상대응설정_메일 where idx = ${sidx}";
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

      String sql = "select * from 이상대응설정_메일 where 정책ID = '${widget.idx}'";

      TCubeAPI ca = TCubeAPI();
      await dsRows.getDataSet(sql);

      if (dsRows.getRowCount() > 0) {
        for (int rr = 0; rr < dsRows.getRowCount(); rr++) {
          drPol = dsRows.rows[rr];

          String idx = drPol.value("idx");

          dicKeyValue["${idx}.사용"] = drPol.value("사용");
          getEdit("${idx}.수신자이메일")!.text = drPol.value("수신자이메일");
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
                "이상대응설정_메일",
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
}
