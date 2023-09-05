import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:three_youth_app/utils/color.dart';

import '../php/classCubeAPI.dart';
import '../php/classCubeTableViewerScreen.dart';

Widget uiText1(String txt) {
  Color cFont = ColorAssets.fontDarkGrey;
  return Text(
    txt,
    style: TextStyle(
      fontSize: 16,
      color: cFont,
      fontWeight: FontWeight.w900,
    ),
    textAlign: TextAlign.start,
    textScaleFactor: 1.0,
  );
}

Widget uiText2(
  String txt, {
  Color cFont = ColorAssets.fontMedGrey,
  bool isBold = false,
}) {
  return Text(
    txt,
    style: TextStyle(
      color: cFont,
      fontSize: 14.0,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    ),
    textScaleFactor: 1.0,
  );
}

Widget uiText3(
  String txt, {
  Color cFont = ColorAssets.fontMedGrey,
  bool isBold = false,
  TextAlign txtAlign = TextAlign.center,
}) {
  return Text(
    txt,
    style: TextStyle(
      color: cFont,
      fontSize: 14.0,
    ),
    textScaleFactor: 1.0,
    textAlign: txtAlign,
  );
}

Widget uiText4(
  String txt, {
  Color cFont = ColorAssets.fontMedGrey,
  bool isBold = false,
  TextAlign txtAlign = TextAlign.center,
  double size = 12,
}) {
  // Color cFont = ColorAssets.fontLightGrey;
  return Text(
    txt,
    style: TextStyle(
      color: cFont,
      fontSize: size,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    ),
    textScaleFactor: 1.0,
    textAlign: txtAlign,
  );
}

Widget uiTopLine() {
  return Container(
    height: 1,
    // padding: EdgeInsets.only(left: 20, right: 20),
    decoration: BoxDecoration(
      color: Color(0xfff9fafb),
      // shape: BoxShape.rectangle,
      // borderRadius: BorderRadius.circular(8.0),
      border: Border(
        top: BorderSide(width: 1.0, color: ColorAssets.borderGrey),
      ),
    ),
  );
}

Map<String, TextEditingController> dicEdtCtrl = Map();
Map<String, GlobalKey<FormFieldState>> dicEdtKey = Map();

Map<String, String> dicKeyValue = Map();
Map<String, List<String>> dicComboItems = Map();

const List<String> _action_list = ["없음", "시스템Reboot", "시스템Shutdown"];

Widget uiCombo(String key, {List<String>? values}) {
  if (values!.length > 0) {
    dicComboItems[key] = values;
  }

  return Container(
    height: 40,
    child: DropdownButton<String>(
      value: dicKeyValue[key],
      items: dicComboItems[key]!.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: uiText4(
            value,
          ),
        );
      }).toList(),
      // Step 5.
      onChanged: (String? newValue) {
        dicKeyValue[key] = newValue!;
      },
    ),
  );
}

TextEditingController? getEdit(String key) {
  if (dicEdtCtrl.containsKey(key) == false)
    dicEdtCtrl[key] = TextEditingController();

  if (dicEdtKey.containsKey(key) == false)
    dicEdtKey[key] = GlobalKey<FormFieldState>();

  return dicEdtCtrl[key];
}

Widget uiEdt(
  String title,
  String key, {
  String description = "",
  String dft = "",
  double width = 100,
  bool isTitle = false,
  TextAlign txtAlign = TextAlign.left,
}) {
  TextEditingController? cc;
  GlobalKey<FormFieldState>? kk;

  if (dicEdtCtrl.containsKey(key) == false)
    dicEdtCtrl[key] = TextEditingController();

  if (dicEdtKey.containsKey(key) == false)
    dicEdtKey[key] = GlobalKey<FormFieldState>();

  cc = dicEdtCtrl[key];
  kk = dicEdtKey[key];

  if (dft != "") {
    cc?.text = dft;
  }

  return Container(
    width: width,
    // decoration: BoxDecoration(
    //   color: Color(0xffeff0f2),
    //   borderRadius: BorderRadius.all(
    //     Radius.circular(5),
    //   ),
    // ),
    // padding: EdgeInsets.only(left: 10, right: 10),
    child: Column(
      children: [
        isTitle
            ? uiText4(
                title,
              )
            : SizedBox(),
        SizedBox(height: 5),
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: Color(0xffeff0f2),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: TextFormField(
              style: TextStyle(color: ColorAssets.fontDarkGrey, fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                suffixIconConstraints: BoxConstraints(maxHeight: 20),
                border: InputBorder.none,
                labelText: description,
                labelStyle: TextStyle(
                  color: ColorAssets.fontDarkGrey,
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              controller: cc,
              textInputAction: TextInputAction.next,
              key: kk,
              textAlign: txtAlign,
              // keyboardType: TextInputType.emailAddress,
              onChanged: (value) async {
                // if(key.contains('macselected'))
                // {
                //
                // }
                // else {
                //   await prefSetting.setString(key, value);
                // }
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget uiMemo(
  BuildContext context,
  String title,
  String description,
  String key, {
  String dft = "",
  double width = 100,
  bool isTitle = false,
  TextAlign txtAlign = TextAlign.left,
}) {
  TextEditingController? cc;
  GlobalKey<FormFieldState>? kk;

  if (dicEdtCtrl.containsKey(key) == false)
    dicEdtCtrl[key] = TextEditingController();

  if (dicEdtKey.containsKey(key) == false)
    dicEdtKey[key] = GlobalKey<FormFieldState>();

  cc = dicEdtCtrl[key];
  kk = dicEdtKey[key];

  if (dft != "") {
    cc?.text = dft;
  }

  return Container(
    width: width,
    // decoration: BoxDecoration(
    //   color: Color(0xffeff0f2),
    //   borderRadius: BorderRadius.all(
    //     Radius.circular(5),
    //   ),
    // ),
    // padding: EdgeInsets.only(left: 10, right: 10),
    child:
    // Stack(
    //   children: [
        Column(
          children: [
            isTitle
                ? uiText4(
                    title,
                  )
                : SizedBox(),
            SizedBox(height: 5),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xffeff0f2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Center(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // Set this
                    expands: true, // and this
                    style: TextStyle(
                        color: ColorAssets.fontDarkGrey, fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                      suffixIconConstraints: BoxConstraints(maxHeight: 20),
                      border: InputBorder.none,
                      labelText: description,
                      labelStyle: TextStyle(
                        color: ColorAssets.fontDarkGrey,
                        fontSize: 12,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    controller: cc,
                    // textInputAction: TextInputAction.next,
                    key: kk,
                    textAlign: txtAlign,

                  ),
                ),
              ),
            ),
        //   ],
        // ),
        // Padding(
        //   padding: EdgeInsets.all(20),
        //   child: uiText4("스크립트코드"),
        // ),
      ],
    ),
  );
}

String getDTToString() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  return formattedDate;
}

Future<void> doPolicyDialog(double ww, double hh, BuildContext context, TRowVoidFunc func) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("모니터링 정책을 선택하세요."),
          content:
              Container(width: ww, height: hh,child:
          CubeTableViewerScreenStatefulWidget(
            table: "모니터링정책_목록",
            sql: "",
            cellHeight: 24,
            fontSize: 12,
            iIdxStyle: 0,
            isEditable: false,
            isSelectable: true,
            onSelectRow: (TRow drParam) {
              func(drParam);
            },
          ),),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('취소'),
            ),
          ],
        );
      });
}

Future<void> doInputDialog(String msg, String dft, BuildContext context, VoidCallback func) async {
  getEdit("doInputDialog")!.text = dft;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(msg),
          content: TextField(
            controller: getEdit("doInputDialog"),
            decoration: InputDecoration(hintText: msg),
          ),
          actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () { func(); },
            child: Text('확인'),
          ),
        ],
        );
      });
}