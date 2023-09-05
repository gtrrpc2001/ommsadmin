import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'classCubeAPI.dart';

class CubeTableViewerStatefulWidget extends StatefulWidget {
  String table = "";
  String sql = "";
  double cellHeight = 24;
  double fontSize = 10;
  int iIdxStyle = 0;
  TDataSet? dsResult;

  CubeTableViewerStatefulWidget(
      {Key? key,
      required this.table,
      required this.sql,
      required this.cellHeight,
      required this.fontSize,
      required this.iIdxStyle})
      : super(key: key);

  @override
  State<CubeTableViewerStatefulWidget> createState() =>
      _CubeTableViewerStatefulWidget();
}

class _CubeTableViewerStatefulWidget
    extends State<CubeTableViewerStatefulWidget> {
  Future<TDataSet> getDataSet(String cmd) async {
    Map<String, String> mp = {
      'table': widget.table,
      'where': widget.sql,
    };
    TDataSet ds = new TDataSet();
    await ds.getDataSetCube(mp);

    widget.dsResult = ds;

    return ds;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TDataSet>(
      future: getDataSet(""),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? getDataTalbe(snapshot.data!)
            : Center(child: CircularProgressIndicator());
      },
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

  Widget getDataTalbe(TDataSet ds) {
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
          getFilterBox(),
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

  Icon getIcon(String txt)
  {
    double iSize = 16;
    IconData icon = Icons.info_outline;
    if(txt == "userud") icon = Icons.devices;

    return Icon(icon, size: iSize,);
  }

  List<Widget> getColumns(TDataSet ds) {
    List<Widget> ll = [];
    ds.cols.forEach((colSetting) {
      String colName = colSetting.value('필드');
      String colDsp =
          colSetting.value('명칭') != null ? colSetting.value('명칭') : '';
      if (colDsp == '') colDsp = colName;

      if (colDsp == 'idx') colDsp = 'No.';

      if (ds.colVisible(colName)) {
        double colWidth = double.tryParse(colSetting.value('width')) ??
            100; // dicCols['Width']);

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
              SizedBox(width: 20, child:
              getIcon(colName),),
              Align(
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
            ],
          ),
        ));
      }
    });
    return ll;
  }

  List<Widget> getDataCellsInRow(TDataSet ds, int r) {
    List<Widget> ll = [];

    TRow dr = ds.rows[r];
    ds.colsInfo.values.forEach((drCol) {
      String col = drCol.value('필드');

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
        Alignment alv = Alignment.centerLeft;
        if (vKind == "int")
          alv = Alignment.centerRight;
        else if (vKind == "DateTime")
          alv = Alignment.centerRight;
        else if (vKind == "String" && widget.table == "기업수요_요약_목록") {
          alv = Alignment.centerLeft;
          v = v.substring(0, 2) + "***";
        }

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
    });

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
