import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:universal_html/prefer_universal/html.dart';

class gv {
  //Singleton
  gv._internal();
  static final gv instance = gv._internal();
  factory gv() {
    return instance;
  }

  // String get sessionId => window.localStorage['SessionId'];
  // set sessionId(String sid) => (sid == null) ? window.localStorage.remove('SessionId') : window.localStorage['SessionId'] = sid;

  static bool isAdmin() {
    bool r = false;

    //SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;

    return true; //prefs.getString("empperm") == "관리자" ? true : false;
  }
}

class TCubeAPI {
  String serverhost = 'dair.co.kr';
  String urlbase = '/omms/api/';
  String urlimage = '/omms/resource/';
  
  TCubeAPI();

  Future<String> dicToTable(String table, Map<String, String> dic, {String where = ""}) async
  {
    String sr = "";

    String sql = "";

    if (where == "") {
      String cols = dic.keys.join(",");
      String values = dic.values.join(",");
      sql = "insert into ${table} (${cols}) values (${values});";
    }
    else
      {
        List<String> ll = [];
        dic.forEach((k,v) => {
          ll.add("${k} = ${v}")
        });
        sql = "update ${table} set ${ll.join(",")} where ${where};";
      }

    sr = await sqlExecPost(sql);

    return sr;
  }

  Future<String> getPDFUrl(String sql) async {
    http.Client client = http.Client();
    print('log : classCubeApi - TCubeAPI');
    Map<String, String> mp = {};
    mp['cmd'] = sql;
    var url = Uri.http(serverhost, urlbase + 'api_getpdfurl.php', mp);
    String sv = '';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String ss = utf8.decode(response.bodyBytes);
      try {
        var jsonResponse = json.decode(ss);
        sv = jsonResponse['result'];
      }
      catch(err){
        sv = '';
      }
    } else {

    }

    return sv;
  }

  Future<String> sqlToText(String sql) async {
    String sr = "";

    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['sql'] = sql;

    // var url = Uri.http("dair.co.kr:80", "/dair/hb/api_getdata.php", mp);
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getdata_post.php');
    var url = Uri.http(serverhost, urlbase + 'api_getdataset_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));

      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //return compute(parseListRow, utf8.decode(response.bodyBytes));
      sr = utf8.decode(response.bodyBytes);

      if (sr.length == 0) {
        sr = "";
        return sr;
      }
      if (sr == "null") {
        sr = "";
        return sr;
      }

      List<TRow> lr = parseListRow(sr);
      if (lr.isNotEmpty) {
        sr = lr[0].dicCols.values.first.toString();
      } else {
        sr = "";
      }
      return sr;
    } catch (E) {
      print(E);
      sr = E.toString();
      return sr;
    }
  }

  Future<int> sqlToInt(String sql) async {
    int sr = -1;

    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['sql'] = sql;

    // var url = Uri.http("dair.co.kr:80", "/dair/hb/api_getdata.php", mp);
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getdata_post.php');
    var url =
        Uri.http(serverhost, urlbase + 'api_getdataset_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));

      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //return compute(parseListRow, utf8.decode(response.bodyBytes));
      String ss = utf8.decode(response.bodyBytes);

      if (ss.length == 0) {
        sr = 0;
        return sr;
      }
      if (ss == "null") {
        sr = -1;
        return sr;
      }

      List<TRow> lr = parseListRow(ss);
      if (lr.isNotEmpty) {
        String sno = lr[0].dicCols.values.first.toString();
        int? ii = int.tryParse(sno);
        if (ii == null)
          sr = -1;
        else
          sr = ii;
      } else {
        sr = 0;
      }
    } catch (E) {
      print(E);
    }
    return sr;
  }

  List<TRow> parseListRow(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<TRow>((json) => TRow.fromJson(json)).toList();
  }

  Future<String> sqlToText2(String sql) async {
    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['cmd'] = sql;
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getcmd.php', mp);
    var url = Uri.http(serverhost, urlbase + 'api_getemd.php', mp);
    String sv = '';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      sv = jsonResponse['result'];
      print(sv);
    } else {
      // print('Request failed with status: ${response.statusCode}.');
    }
    return sv;
    // return compute(parseJson, response.body);
  }

  Future<String> sqlToText3(String sql) async {
    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['cmd'] = sql;
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getcmd.php', mp);
    var url = Uri.http(serverhost, urlbase + 'api_getemdall.php', mp);
    String sv = '';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      sv = jsonResponse['result'];
      print(sv);
    } else {
      // print('Request failed with status: ${response.statusCode}.');
    }
    return sv;
    // return compute(parseJson, response.body);
  }

  Future<String> sqlToText4(String sql) async {
    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['cmd'] = sql;
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getcmd.php', mp);
    var url = Uri.http(serverhost, urlbase + 'api_getemdall_1.php', mp);
    String sv = '';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      sv = jsonResponse['result'];
      //print(sv);
    } else {
      // print('Request failed with status: ${response.statusCode}.');
    }
    return sv;
    // return compute(parseJson, response.body);
  }

  Future<String> sqlExecPost(String sql) async {
    String sr = "";

    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['sql'] = sql;

    // var url = Uri.http("dair.co.kr:80", "/dair/hb/api_getdata.php", mp);
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getdata_post.php');
    var url = Uri.http(serverhost, urlbase + 'api_getcmd_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));

      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //return compute(parseListRow, utf8.decode(response.bodyBytes));
      sr = utf8.decode(response.bodyBytes);

      return sr;
    } catch (E) {
      print(E);
      print(sr);
      return sr;
    }
  }

  Future<String> sqlExec(String sql) async {
    http.Client client = http.Client();

    Map<String, String> mp = {};
    mp['cmd'] = sql;
    print("api_exe cmd : " + sql);
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_execmd.php', mp);
    var url = Uri.http(serverhost, urlbase + 'api_execmd.php', mp);
    String sv = '';

    final response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      sv = jsonResponse['result'];
      //  print(sv);
    } else {
      // print('Request failed with status: ${response.statusCode}.');
    }
    return sv;
    // return compute(parseJson, response.body);
  }

  // String parseJson(String responseBody) {
  //   final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  //
  //   return parsed.map<TRow>((json) => TRow.fromJson(json)).toList();
  // }
  static getDTToString() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }
}

class TRow {
  List<String> Cols = <String>[];
  Map dicCols = {};
  bool selected = false;

  bool isReady = false;

  TRow();

  factory TRow.fromJson(Map<String, dynamic> json) {
    TRow rr = TRow();
    json.forEach((key, value) {
      try {
        rr.dicCols[key.toLowerCase()] = value;
      }catch(E)
      {
        print(E);
      }
    });

    return rr;
  }

  String value(String col) {
    String sr = "";
    col = col.toLowerCase();
    if (dicCols.containsKey(col)) {
      if (dicCols[col] == null)
        sr = "";
      else
        sr = dicCols[col];
    } else {
      sr = "";
    }
    return sr;
  }

  double asdouble(String col) {
    String sr = "";
    double dr = 0;
    col = col.toLowerCase();
    if (dicCols.containsKey(col)) {
      if (dicCols[col] == null)
        sr = "";
      else
        sr = dicCols[col];
    } else {
      sr = "";
    }

    dr = double.tryParse(sr) ?? 0;

    return dr;
  }

  int asint(String col) {
    String sr = "";
    int dr = 0;
    col = col.toLowerCase();
    if (dicCols.containsKey(col)) {
      if (dicCols[col] == null)
        sr = "";
      else
        sr = dicCols[col];
    } else {
      sr = "";
    }

    dr = int.tryParse(sr) ?? 0;

    return dr;
  }
}

class TDataSet {
  String serverhost = 'dair.co.kr';
  String urlbase = '/omms/api/';
  String urlimage = '/omms/resource/';

  List<TRow> rows = [];
  List<bool> selected = [];
  Map<String, TRow> colsInfo = {};
  Map<String, TRow> designInfo = {};
  List<TRow> cols = [];
  bool isReady = false;

  //String Table = '인원_목록';

  TDataSet();

  Future<void> getDataSetCube(Map<String, String> mp) async {
    rows = await fetchRows(mp) as List<TRow>;

    // 2) table setting
    Map<String, String> mpTableSetting = new Map();
    mpTableSetting['table'] = '_table_setting';
    mpTableSetting['cols'] = '';
    mpTableSetting['where'] = ' 테이블 = \'' + mp['table'].toString() + '\' ';

    colsInfo = await fetchDicRows(mpTableSetting, '필드');

    colsInfo.forEach((key, value) {
      cols.add(value);
    });

    // 3) table design
    mpTableSetting.clear();
    mpTableSetting['table'] = '_table_filter_design';
    mpTableSetting['cols'] = '';
    mpTableSetting['where'] = " 키 = '테이블_" + mp["table"].toString() + "' ";
    designInfo = await fetchDicRows(mpTableSetting, 'idx');

    String sql = "select * from ${mp["table"]} ";
    if (mp["where"].toString().length > 0)
    {
      sql = sql + " ${mp["where"]}";
    }
    await getDataSet(sql);
  }

  Future<void> getDataSet(String sql) async {
    Map<String, String> mp = {
      'sql': sql,
    };

    rows = await fetchDataSet(mp);
  }

  Future<List<TRow>> fetchDataSet(Map<String, String> mp) async {
    http.Client client = http.Client();
    String sr = "";

    // var url = Uri.http("dair.co.kr:80", "/dair/hb/api_getdata.php", mp);
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getdata_post.php');
    var url = Uri.http(serverhost, urlbase + 'api_getdataset_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));

      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //return compute(parseListRow, utf8.decode(response.bodyBytes));
      sr = utf8.decode(response.bodyBytes);

      return parseListRow(sr);
    } catch (E) {
      print(E);
      print(sr);
      List<TRow> ll = <TRow>[];
      return ll;
    }
  }

  Future<void> getDataSetSetting(Map<String, String> mp) async {
    rows = await fetchRows(mp);

    // 2) table setting
    Map<String, String> mpTableSetting = {};
    mpTableSetting['table'] = '_table_setting';
    mpTableSetting['cols'] = '';
    mpTableSetting['where'] = ' 테이블 = \'' + mp['table'].toString() + '\' ';

    colsInfo = await fetchDicRows(mpTableSetting, '필드');

    colsInfo.forEach((key, value) {
      cols.add(value);
    });

    // 3) table design
    mpTableSetting.clear();
    mpTableSetting['table'] = '_table_filter_design';
    mpTableSetting['cols'] = '';
    mpTableSetting['where'] = " 키 = '테이블_" + mp["table"].toString() + "' ";
    designInfo = await fetchDicRows(mpTableSetting, 'idx');
  }

  bool colVisible(String col) {
    if (colsInfo.containsKey(col)) {
      String v = colsInfo[col]!.dicCols['표시'];
      String v2 = colsInfo[col]!.dicCols['숨기기'];
      if (v == '1' && v2 == "0") {
        return true;
      }
    }
    return false;
  }

  Map col(String col) {
    return colsInfo[col]!.dicCols;
  }

  Future<List<TRow>> fetchRows(Map<String, String> mp) async {
    String sr = "";

    var url = Uri.http(serverhost, urlbase + 'api_getdata_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));

      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      //return compute(parseListRow, utf8.decode(response.bodyBytes));
      sr = utf8.decode(response.bodyBytes);

      if(sr.contains("CAN'T RETRIEVE FROM MYSQL"))
      {
        return [];
      }

      return parseListRow(sr);
    } catch (E) {
      print(E);
      print(sr);
      List<TRow> ll = <TRow>[];
      return ll;
    }
  }

  List<TRow> parseListRow(String responseBody) {
    responseBody = responseBody.replaceAll('\n', '');
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<TRow>((json) => TRow.fromJson(json)).toList();
  }

  Future<Map<String, TRow>> fetchDicRows(
      Map<String, String> mp, String Key) async {
    // http.Client client = http.Client();
    //var url = Uri.http('dair.co.kr:80', '/dair/hb/api_getdata_post.php');
    var url = Uri.http(serverhost, urlbase + 'api_getdata_post.php');

    try {
      final response = await http.post(url,
          // headers: {
          //   "Content-Type": "application/json"
          // },
          body: jsonEncode(mp));
      if (response.statusCode == 200) {
        // var jsonResponse = convert.jsonDecode(response.body);
        // var itemCount = jsonResponse['totalItems'];
        // print('Number of books about http: $itemCount.');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

      Map mpResult = {};
      String sr = utf8.decode(response.bodyBytes);
      mpResult['response'] = sr;
      mpResult['key'] = Key;

      if(sr.contains("CAN'T RETRIEVE FROM MYSQL"))
        {
          return Map();
        }
      //return compute(parseDicRow, mpResult);
      return parseDicRow(mpResult);
    } catch (E) {
      print(E.toString());
      Map<String, TRow> ll = <String, TRow>{};
      return ll;
    }
  }

  Map<String, TRow> parseDicRow(Map mp) {
    String responseBody = mp['response'];
    String key = mp['key'];

    // print(responseBody);

    Map<String, TRow> _dic = {};

    try {
      final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

      List<TRow> listRow =
          parsed.map<TRow>((json) => TRow.fromJson(json)).toList();

      for (var row in listRow) {
        _dic[row.dicCols[key.toLowerCase()]] = row;
      }
    } on FormatException {
      print('-------------------------------------');
      print('The provided string is not valid JSON');
      print(responseBody);
    }

    return _dic;
  }

  int getRowCount() {
    return isReady ? 0 : rows.length;
  }
}

class CubeStorage {
  final _fileName;

  String _path = '';

  CubeStorage(this._fileName) {
    init();
  }

  void init() async {
    final directory = await getApplicationDocumentsDirectory();

    _path = directory.path;
  }

  Future<String> readFile() async {
    try {
      final file = File('$_path/$_fileName');

      return file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> writeFile(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _path = directory.path;
      final path = Directory('$_path/save/');
      if ((await path.exists())){
      }else{
        path.create();
      }

      final file = File('$_path/save/$_fileName');

      file.writeAsString(message, mode: FileMode.append);
    } catch (e) {
      print(e);
    }
  }
}
