import 'dart:async';
import 'package:flutter/material.dart';
import 'package:three_youth_app/utils/color.dart';

class BackAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BackAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  _BackAppBarState createState() => _BackAppBarState();
}

class _BackAppBarState extends State<BackAppBar> {
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
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
      flexibleSpace: new Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xff4394c7),
              Color(0xff005ba5),
            ],
          ),
        ),
      ),

      leading: SizedBox(
        width: 50,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ColorAssets.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
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
                'assets/images/glogo2.png',
                fit: BoxFit.fitHeight,
              ),
              Text("겟블루"),
              // SizedBox(width: 10,),
              // Text("클라우드 관로/관망/제수변 관리 시스템",
              //   style: TextStyle(
              //       fontSize: 12,
              //       color: Colors.white
              //   ),
              // ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: const [],
    );
  }
}
