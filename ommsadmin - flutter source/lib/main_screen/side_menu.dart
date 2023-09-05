import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class uiSideMenu extends StatelessWidget {
  const uiSideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: Icon(Icons.monitor,color: Colors.white),
            press: () {

            },
          ),
          DrawerListTile(
            title: "Transaction",
            svgSrc: Icon(Icons.monitor,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Task",
            svgSrc: Icon(Icons.monitor,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Documents",
            svgSrc: Icon(Icons.monitor,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Store",
            svgSrc: Icon(Icons.monitor,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Notification",
            svgSrc: Icon(Icons.notifications,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: Icon(Icons.info_rounded,color: Colors.white),
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: Icon(Icons.settings,color: Colors.white),
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final Icon svgSrc;
  final String title;//, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: svgSrc,//Icon(Icons.monitor,color: Colors.white), //add icon
      // SvgPicture.asset(
      //   svgSrc,
      //   color: Colors.white54,
      //   height: 16,
      // ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
