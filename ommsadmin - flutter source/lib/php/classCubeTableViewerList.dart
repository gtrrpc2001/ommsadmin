import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

import 'classCubeAPI.dart';

class CubeTableViewerListStatefulWidget extends StatefulWidget {
  String table = "";
  String sql = "";
  double cellHeight = 24;
  double fontSize = 10;
  int iIdxStyle = 0;
  TDataSet? dsResult;

  CubeTableViewerListStatefulWidget(
      {Key? key,
      required this.table,
      required this.sql,
      required this.cellHeight,
      required this.fontSize,
      required this.iIdxStyle})
      : super(key: key);

  @override
  State<CubeTableViewerListStatefulWidget> createState() =>
      _CubeTableViewerStatefulWidget();
}

class _CubeTableViewerStatefulWidget
    extends State<CubeTableViewerListStatefulWidget> {
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
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Row(
              //     children: [ Text("")],
              //   ),
              // ),
              Expanded(
                child: SizedBox(),
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

    List<bool>.generate(ds.getRowCount(), (int index) => false);
    ds.isReady = true;

    return Container(
      child: Column(
        children: [
          getFilterBox(),
          Expanded(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: ListView.builder(
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
        double colWidth = double.tryParse(colSetting.value('Width')) ?? 100;

        ll.add(new Container(
          height: widget.cellHeight,
          width: colWidth,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              colDsp,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
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
        double colWidth = double.parse(ds.colsInfo[col]!.value('Width'));

        String v = '';
        if (dr.value(col) != null) {
          v = dr.value(col);
        }

        String vKind = isNumericUsing_tryParse(v) ? "int" : isDateUsing_tryParse(v) ? "DateTime" : "String";
        Alignment alv = Alignment.centerLeft;
        if (vKind == "int")
          alv = Alignment.centerRight;
        else if (vKind == "DateTime") alv = Alignment.centerRight;

        else if(vKind == "String"&& widget.table =="기업수요_요약_목록")
          {
            alv = Alignment.centerLeft;
            v  = v.substring(0,2) +"***";
          }

        ll.add(new Container(
          height: widget.cellHeight,
          width: colWidth,
          padding: EdgeInsets.only(right: 55, left: 5),
          child: Align(
            alignment: alv,
            child: Text(
              v,
              style: TextStyle(
                fontSize: widget.fontSize,
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

