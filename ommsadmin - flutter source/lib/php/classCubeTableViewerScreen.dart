import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:three_youth_app/base/uiBase.dart';
import 'package:three_youth_app/utils/toast.dart';
// import 'package:http/http.dart' as http;

import '../omms/agentpolicy_screen.dart';
import '../utils/color.dart';
import 'classCubeAPI.dart';

typedef TRowVoidFunc = void Function(TRow);

class CubeTableViewerScreenStatefulWidget extends StatefulWidget {
  String table = "";
  String sql = "";
  double cellHeight = 24;
  double fontSize = 10;
  int iIdxStyle = 0;
  TDataSet? dsResult;

  bool isEditable = true;
  bool isSelectable = false;

  TRowVoidFunc onSelectRow;

  CubeTableViewerScreenStatefulWidget(
      {Key? key,
        required this.table,
        required this.sql,
        required this.cellHeight,
        required this.fontSize,
        required this.iIdxStyle,
        required this.isEditable,
        required this.isSelectable,
        required this.onSelectRow,
      })
      : super(key: key);

  @override
  State<CubeTableViewerScreenStatefulWidget> createState() =>
      _CubeTableViewerScreenStatefulWidget();
}

class _CubeTableViewerScreenStatefulWidget
    extends State<CubeTableViewerScreenStatefulWidget> {
  bool isLoading = true;
  late final double _screenHeight;
  late final double _screenWidth;

  Future<bool>? taskReload;

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

  Future<bool> doReload() async {
    try {
      Map<String, String> mp = {
        'table': widget.table,
        'where': widget.sql,
      };
      TDataSet ds = new TDataSet();
      await ds.getDataSetCube(mp);
      widget.dsResult = ds;
    } catch (E) {}

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorAssets.commonBackgroundDark,
      body: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: ColorAssets.borderGrey,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        padding: EdgeInsets.all(10),
        child: FutureBuilder<bool>(
          future: taskReload,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            if (snapshot.connectionState == ConnectionState.done) {
              return dsToUI();
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget uiToolBox() {
    return Container(
      height: 50,
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              Map<String, String> dic = Map();
              dic["idx"] = "0";

              TCubeAPI ca = TCubeAPI();
              await ca.dicToTable(
                widget.table,
                dic,
              );

              setState(() {
                taskReload = doReload();
              });
            },
            child: widget.isEditable ? Text(
              "추가",
              style: TextStyle(fontSize: 12.0),
              textScaleFactor: 1.0,
            ) : SizedBox(),
          ),
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

  Widget getFilterBox() {
    if (widget.dsResult != null) {
      if (widget.dsResult!.designInfo.length > 0) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey, width: 0.5, style: BorderStyle.solid),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: widget.dsResult!.designInfo.values.map((row) {
                    return Container(
                      width: 120,
                      margin: EdgeInsets.only(right: 5),
                      child: getEditBox(row.value("표시")),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: SizedBox(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 40,
                      child: OutlinedButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder()),
                        ),
                        label: Text('조회'),
                        icon: Icon(Icons.search),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        );
      }
    }
    return SizedBox(
      height: 0,
    );
  }

  Widget getEditBox(String hintText) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: EdgeInsets.only(left: 10.0),
      decoration: new BoxDecoration(
        //shape: BoxShape.rectangle,
        //color: const Color(0xff456ADB),
        border: new Border.all(width: 1, color: Color(0xffe0e0e0)),
      ),
      child: Center(
        child: TextField(
          //controller: ctrl,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: TextStyle(fontSize: 14.0, color: Colors.grey),
        ),
      ),
    );
  }

  Widget dsToUI() {
    TDataSet ds = widget.dsResult ?? TDataSet();

    if (ds.selected.length != ds.rows.length) {
      ds.selected = List.generate(ds.rows.length, (index) => false);
    }
    // if (getRowCount() == 0) {
    //   return Container(
    //     child: Center(
    //       child: Text('데이터가 없습니다.'),
    //     ),
    //   );
    // }
    List<bool>.generate(ds.getRowCount(), (int index) => false);
    ds.isReady = true;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // getFilterBox(),
          uiToolBox(),
          Expanded(
            child: SingleChildScrollView(
              // scrollDirection: Axis.horizontal,
              physics: ScrollPhysics(),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: ds.rows.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0)
                    return Column(children: [
                      Row(
                        children: getColumns(ds),
                      ),
                      Divider(),
                    ]);

                  return Column(children: [
                    Row(children: getDataCellsInRow(ds, index)),
                    Divider(),
                  ]);
                },
              ),
            ),
          ),
        ],
      ),
    );

    // return Container(
    //   width: double.infinity,
    //   height: double.infinity,
    //   child: Scrollbar(
    //     isAlwaysShown: true,
    //     controller: _firstController,
    //     child: DataTable(
    //       columns: getColumns(ds),
    //       rows: List<DataRow>.generate(
    //         ds.rows.length,
    //             (int r) => DataRow(cells: getDataCellsInRow(ds, r)
    //
    //           // selected: selected[r],
    //           // onSelectChanged: (bool? value) {
    //           //   setState(() {
    //           //     selected[r] = value!;
    //           //   });
    //           // },
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Icon getIcon(String txt) {
    double iSize = 16;
    IconData icon = Icons.info_outline;
    if (txt == "userud") icon = Icons.devices;

    return Icon(
      icon,
      size: iSize,
    );
  }

  List<Widget> getColumns(TDataSet ds) {
    List<Widget> ll = [];
    ds.cols.forEach((colSetting) {
      String colName = colSetting.value('필드');
      String colDsp =
          colSetting.value('명칭') != null ? colSetting.value('명칭') : '';
      if (colDsp == '') colDsp = colName;

      if (colDsp == 'idx')
      {
        if (widget.table == "모니터링정책_목록")
          colDsp = "관리번호";
        else
          colDsp = 'No.';
      }

      if (ds.colVisible(colName)) {
        double colWidth = double.tryParse(colSetting.value('width')) ??
            100; // dicCols['Width']);

        if (colName == "idx" && widget.isEditable)
        {
           colWidth = 100;
        }

        {
          ll.add(Container(
            height: widget.cellHeight,
            width: colWidth,
            // decoration: BoxDecoration(
            //   border: Border(
            //     bottom: BorderSide(
            //         color: Colors.grey, width: 0.5, style: BorderStyle.solid),
            //   ),
            // ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: getIcon(colName),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      colDsp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        // color: Color(0xff333333),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ));
        }
      }
    });
    return ll;
  }

  Widget uiPopupScreen(String table, TRow dr) {
    if (table == "모니터링정책_목록") {
      return AgentPolicyScreen(idx: dr.value("idx"));
    } else {
      return SizedBox();
    }
  }

  List<Widget> getDataCellsInRow(TDataSet ds, int r) {
    List<Widget> ll = [];

    TRow dr = ds.rows[r];
    ds.colsInfo.values.forEach((drCol) {
      String col = drCol.value('필드');

      if (col == "idx" && widget.isEditable) {
        return ll.add(
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        // insetPadding: EdgeInsets.all(0),
                        content: Container(
                          // decoration: BoxDecoration(
                          //   color: ColorAssets.white,
                          //   borderRadius: BorderRadius.all(
                          //     Radius.circular(20),
                          //   ),
                          //   border: Border.all(
                          //     color: ColorAssets.borderGrey,
                          //     width: 1,
                          //   ),
                          // ),
                          height: _screenHeight * 0.8,
                          width: _screenWidth * 0.8,
                          // padding: const EdgeInsets.only(right: 10, left: 10),
                          child: uiPopupScreen(widget.table, dr),
                        ),
                      );
                    });
              },
              child: Text(
                "편집",
                style: TextStyle(fontSize: 12.0),
                textScaleFactor: 1.0,
              ),
            ),
          ),
        );
      }

      else if (col == "idx" && widget.isSelectable) {
        return ll.add(
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelectRow(dr);
                 // dicKeyValue['polselectedidx'] = dr.value("idx");
                 // Navigator.of(context).pop();
              },
              child: Text(
                "선택",
                style: TextStyle(fontSize: 12.0),
                textScaleFactor: 1.0,
              ),
            ),
          ),
        );
      }

      else {
        if (ds.colVisible(col)) {
          double colWidth = double.tryParse(ds.colsInfo[col]!.value('width')) ??
              100; // dicCols['Width']);

          String v = '';
          v = dr.value(col);

          String vKind = isNumericUsing_tryParse(v)
              ? "int"
              : isDateUsing_tryParse(v)
                  ? "DateTime"
                  : "String";
          Alignment alv = Alignment.center;
          // if (vKind == "int")
          //   alv = Alignment.centerRight;
          // else if (vKind == "DateTime")
          //   alv = Alignment.centerRight;
          // else if (vKind == "String" && widget.table == "기업수요_요약_목록") {
          //   alv = Alignment.centerLeft;
          //   v = v.substring(0, 2) + "***";
          // }

          if (col == "사용") {
            ll.add(new Container(
              height: widget.cellHeight,
              width: colWidth,
              padding: EdgeInsets.only(right: 5, left: 5),
              // decoration: new BoxDecoration(
              //   border: new Border(
              //     right: BorderSide(width: 0.5, color: Color(0xffe0e0e0)),
              //   ),
              // ),
              child:  Checkbox(
                activeColor: ColorAssets.fontLightGrey,
                  value: v == "1",
                  onChanged: (value) {
                  }),
            ));
          } else {
            ll.add(new Container(
              height: widget.cellHeight,
              width: colWidth,
              padding: EdgeInsets.only(right: 5, left: 5),
              // decoration: new BoxDecoration(
              //   border: new Border(
              //     right: BorderSide(width: 0.5, color: Color(0xffe0e0e0)),
              //   ),
              // ),
              child: Align(
                alignment: alv,
                child: Text(
                  v,
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    // color: Color(0xff333333),
                  ),
                ),
              ),
            ));
          }
        }
      }
    });

    if (widget.isEditable)
      {
        ll.add(SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: () async {
              String sidx = dr.value("idx");
              String sql = "delete from ${widget.table} where idx = ${sidx}";

              TCubeAPI ca = TCubeAPI();
              await ca.sqlExecPost(sql);

              showToast("삭제 하였습니다.");

              setState(() {
                taskReload = doReload();
              });
            },
            child: Text(
              "삭제",
              style: TextStyle(fontSize: 12.0),
              textScaleFactor: 1.0,
            ),
          ),
        ),
        );

      }

    return ll;
  }

  bool isNumericUsing_tryParse(String string) {
    if (string == null || string.isEmpty) {
      return false;
    }

    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }

  bool isDateUsing_tryParse(String string) {
    if (string == null || string.isEmpty) {
      return false;
    }

    final number = DateTime.tryParse(string);

    if (number == null) {
      return false;
    }

    return true;
  }
}

// class PhotosList extends StatelessWidget {
//   final List<TRow> row;
//
//   PhotosList({required this.row}) : super();
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//       ),
//       itemCount: row.length,
//       itemBuilder: (context, index) {
//         return Text("Test");
//       },
//     );
//   }
// }
