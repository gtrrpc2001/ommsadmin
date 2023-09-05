import 'dart:async';
import 'dart:io';

import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_youth_app/base/back_app_bar.dart';
import 'package:three_youth_app/base/base_app_bar.dart';
import 'package:three_youth_app/base/spinkit.dart';
import 'package:three_youth_app/utils/color.dart';
import 'package:three_youth_app/utils/current_user.dart';

import '../main_screen/side_menu.dart';
import '../php/classCubeAPI.dart';
import '../php/classCubeTableViewer.dart';
import '../php/classCubeTableViewerScreen.dart';
import '../utils/toast.dart';
import 'MonitoringScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key
      // required this.rfid,
      // // required this.pos,
      // required this.lat,
      // required this.lang
      })
      : super(key: key);

  // final String rfid;
  // final double lat;
  // final double lang;
  // final Position pos;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isLoading = true;
  late final double _screenHeight;
  late final double _screenWidth;
  late SharedPreferences prefs;

  PageController pageMenu = PageController();
  SideMenuController sideMenu = SideMenuController();

  int iMenuSelected = 0;

  // String rfid = '';
  // double lat = 0;
  // double lang = 0;

  @override
  void initState() {
    // rfid = widget.rfid;
    // // rfid = '544211';
    // lat = widget.lat;
    // lang = widget.lang;

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      setState(() {
        _screenWidth = MediaQuery.of(context).size.width;
        _screenHeight = MediaQuery.of(context).size.height;
        isLoading = false;
        pageMenu.jumpToPage(3);
      });
    });

    super.initState();
  }

  Widget getMap() {
    return Container(
      child: isLoading
          ? spinkit
          : Center(

            ),
    );
  }

  Widget uiMenu()
  {
    return Drawer(
      backgroundColor: Color(0xff2a2d3e),
      child: ListView(
        children: [
          DrawerHeader(
            child:  Icon(Icons.monitor_heart, color: Colors.white),// Image.asset("assets/images/logo.png"),
          ),
          ExpansionTile(
            collapsedIconColor: Colors.grey,
            initiallyExpanded: true,
            title: Text("모니터링", style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.monitor,color: Colors.white), //add icon
            childrenPadding: EdgeInsets.only(left:20), //children padding
            children: [
              DrawerListTile(
                title: "실시간 현황",
                svgSrc: Icon(Icons.edit_location,color: Colors.white),
                press: () {
                  pageMenu.jumpToPage(0);
                  Navigator.of(context).pop();
                },
              ),
              DrawerListTile(
                title: "이상 로그",
                svgSrc: Icon(Icons.event,color: Colors.white),
                press: () {
                  pageMenu.jumpToPage(1);
                  Navigator.of(context).pop();
                },
              ),
              DrawerListTile(
                title: "전체 로그",
                svgSrc: Icon(Icons.history,color: Colors.white),
                press: () {
                  pageMenu.jumpToPage(2);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          ExpansionTile(
            collapsedIconColor: Colors.grey,
            initiallyExpanded: true,
            title: Text("정책 설정", style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.file_copy,color: Colors.white), //add icon
            childrenPadding: EdgeInsets.only(left:20), //children padding
            children: [
              DrawerListTile(
                title: "정책목록",
                svgSrc: Icon(Icons.timer_sharp,color: Colors.white),
                press: () {
                  pageMenu.jumpToPage(3);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          // ExpansionTile(
          //   collapsedIconColor: Colors.grey,
          //   initiallyExpanded: true,
          //   title: Text("Booking", style: TextStyle(color: Colors.white),),
          //   leading: Icon(Icons.date_range,color: Colors.white), //add icon
          //   childrenPadding: EdgeInsets.only(left:20), //children padding
          //   children: [
          //     DrawerListTile(
          //       title: "List",
          //       svgSrc: Icon(Icons.list_outlined,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(6);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Request",
          //       svgSrc: Icon(Icons.playlist_add,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(7);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Passenger",
          //       svgSrc: Icon(Icons.playlist_add_check_rounded,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(8);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //   ],
          // ),
          //
          // ExpansionTile(
          //   collapsedIconColor: Colors.grey,
          //   initiallyExpanded: true,
          //   title: Text("Setting", style: TextStyle(color: Colors.white),),
          //   leading: Icon(Icons.settings,color: Colors.white), //add icon
          //   childrenPadding: EdgeInsets.only(left:20), //children padding
          //   children: [
          //     DrawerListTile(
          //       title: "Device",
          //       svgSrc: Icon(Icons.directions_car_rounded,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(9);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Users",
          //       svgSrc: Icon(Icons.group,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(10);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Company",
          //       svgSrc: Icon(Icons.warehouse_outlined,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(11);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Group",
          //       svgSrc: Icon(Icons.group_work_outlined,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(12);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "People}",
          //       svgSrc: Icon(Icons.people,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(13);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //   ],
          // ),
          //
          // ExpansionTile(
          //   collapsedIconColor: Colors.grey,
          //   initiallyExpanded: true,
          //   title: Text("Support", style: TextStyle(color: Colors.white),),
          //   leading: Icon(Icons.support,color: Colors.white), //add icon
          //   childrenPadding: EdgeInsets.only(left:20), //children padding
          //   children: [
          //     DrawerListTile(
          //       title: "Notice",
          //       svgSrc: Icon(Icons.notifications,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(14);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //     DrawerListTile(
          //       title: "Version History",
          //       svgSrc: Icon(Icons.manage_history,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(15);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //   ],
          // ),
          //
          // ExpansionTile(
          //   collapsedIconColor: Colors.grey,
          //   initiallyExpanded: true,
          //   title: Text("Help", style: TextStyle(color: Colors.white),),
          //   leading: Icon(Icons.support,color: Colors.white), //add icon
          //   childrenPadding: EdgeInsets.only(left:20), //children padding
          //   children: [
          //     DrawerListTile(
          //       title: "About",
          //       svgSrc: Icon(Icons.info_rounded,color: Colors.white),
          //       press: () {
          //         pageMenu.jumpToPage(16);
          //         Navigator.of(context).pop();
          //       },
          //     ),
          //   ],
          // ),

        ],
      ),
    );

  }

  AppBar uiAppBar()
  {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      backgroundColor: Color(0xff212332),

      flexibleSpace: new Container(
        decoration: BoxDecoration(
          color: Color(0xff212332),
        ),
      ),

      title: Container(
        child: InkWell(
          onTap: () {
            //Navigator.pushNamedAndRemoveUntil(context, '/overview', (route) => false);
          },
          child: Row(
            children: [
              // Image.asset(
              //   'assets/icons/icon_gpstracking.png',
              //   fit: BoxFit.fitHeight,
              // ),

              Text("OMMS"),

              SizedBox(width: 10,),

              Text("OMMS Administrator",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                ),
              ),

              Expanded(child:SizedBox(),),

              Align(alignment: Alignment.centerRight,child:
              ProfileCard()),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        drawer: uiMenu(),
        backgroundColor: ColorAssets.commonBackgroundDark,
        appBar: uiAppBar(),
        //drawer: ,
        body: Stack(
          children: [
            // ppppppppppppppppppppppppppppp
            PageView(
              controller: pageMenu,
              children: [

                Container(
                  child:
                    MonitoringScreen(),
                  // CubeTableViewerScreenStatefulWidget(
                  //   table: "모니터링_현황",
                  //   sql: "",
                  //   cellHeight: 24,
                  //   fontSize: 12,
                  //   iIdxStyle: 0,
                  //   isEditable: false,
                  // ),

                ),
                Container(
                  child:
                  CubeTableViewerScreenStatefulWidget(
                    table: "모니터링_이벤트로그",
                    sql: " order by idx desc limit 100",
                    cellHeight: 28,
                    fontSize: 12,
                    iIdxStyle: 0,
                    isEditable: false,
                    isSelectable: false,
                    onSelectRow: (TRow drParam) {},
                  ),
                ),

                Container(
                  child:
                  CubeTableViewerScreenStatefulWidget(
                    table: "모니터링_로그",
                    sql: " order by idx desc limit 100",
                    cellHeight: 28,
                    fontSize: 12,
                    iIdxStyle: 0,
                    isEditable: false,
                    isSelectable: false,
                    onSelectRow: (TRow drParam) {},
                  ),
                ),

                Container(
                  child:
                    CubeTableViewerScreenStatefulWidget(
                      table: "모니터링정책_목록",
                      sql: "",
                      cellHeight: 28,
                      fontSize: 12,
                      iIdxStyle: 0,
                      isEditable: true,
                      isSelectable: false,
                      onSelectRow: (TRow drParam) {},
                    ),
                ),

              ],
            ),
            // (iMenuSelected == 0) ? getMap() : SizedBox(),

          ],
        ),
      ),
    );
  }
}

