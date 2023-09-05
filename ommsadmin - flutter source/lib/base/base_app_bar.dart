import 'dart:async';
import 'package:flutter/material.dart';
import 'package:three_youth_app/utils/color.dart';

import 'uiBase.dart';

class BaseAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BaseAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  _BaseAppBarState createState() => _BaseAppBarState();
}

class _BaseAppBarState extends State<BaseAppBar> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {});

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      backgroundColor: ColorAssets.white,

      flexibleSpace: new Container(
        decoration: BoxDecoration(
          color: Colors.indigo,
        ),
      ),

      title: Container(
        child: InkWell(
          onTap: () {
            //Navigator.pushNamedAndRemoveUntil(context, '/overview', (route) => false);
          },
          child: Row(
            children: [
              Image.asset(
                'assets/icons/icon_gpstracking.png',
                fit: BoxFit.fitHeight,
              ),

              Text("OMMS Administrator"),

              SizedBox(width: 10,),

              Text("OMMS Administrator",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: const [],
    );
  }
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

AppBar uiAppBarPopup(BuildContext context, String title, Function func)
{
  return AppBar(
    iconTheme: const IconThemeData(color: Colors.black),
    elevation: 0,
    backgroundColor: Colors.white,

    // flexibleSpace: new Container(
    //   decoration: BoxDecoration(
    //     color: Color(0xff212332),
    //   ),
    // ),

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

            uiText1(title),
          ],
        ),
      ),
    ),
    leading: InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back_ios,
        color: Colors.black54,
      ),
    ),
    centerTitle: true,
  );
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: ColorBlueMid,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Image.asset(
          //   "assets/images/profile_pic.png",
          //   height: 38,
          // ),
          Icon(Icons.supervised_user_circle, size: 18),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            child: Text("Admin", style: const TextStyle(color: Colors.white, fontSize: 14),),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}