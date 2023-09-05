import 'package:flutter/material.dart';
import 'package:three_youth_app/utils/color.dart';

Widget uiEdtCtrl(
    TextEditingController cc,
    Key kk
    ) {
  return Container(
    height: 30,
    decoration: BoxDecoration(
      color: Color(0xffeff0f2),
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    // padding: EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        Expanded(
          child: TextFormField(
            style: const TextStyle(
                color: Colors.black87, fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              suffixIconConstraints: BoxConstraints(maxHeight: 20),
              border: InputBorder.none,
              // labelText: '아이디 입력',
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                // fontWeight: FontWeight.bold,
              ),
            ),
            controller: cc,
            textInputAction: TextInputAction.next,
            key: kk,
            textAlign: TextAlign.center,
            // keyboardType: TextInputType.emailAddress,
            onChanged: (value) {},
            // validator: (value) {
            //   //!Error: Pattern pattern => String pattern;
            //   String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            //   RegExp regex = RegExp(pattern);
            //   return (regex.hasMatch(value!)) ? null : '이메일 형식으로 입력해주세요';
            // },
          ),
        ),
      ],
    ),
  );
}

Widget uiEdtUpDown(
    TextEditingController cc,
    Key kk,
    String sunit,
    ) {
  return Container(
    height: 40,
    decoration: BoxDecoration(
      color: Color(0xffeff0f2),
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    // padding: EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(
              Icons.remove_circle,
              color: Colors.black87,
            ),
            onPressed: () {
              try {
                int vv = int.parse(cc.text);
                vv--;
                cc.text = vv.toString();
              } catch (E) {}
            },
          ),
        ),
        Expanded(
          child: TextFormField(
            style: const TextStyle(
                color: Colors.black87, fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              suffixIconConstraints: BoxConstraints(maxHeight: 20),
              border: InputBorder.none,
              // labelText: '아이디 입력',
              labelStyle: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                // fontWeight: FontWeight.bold,
              ),
            ),
            controller: cc,
            textInputAction: TextInputAction.next,
            key: kk,
            textAlign: TextAlign.center,
            // keyboardType: TextInputType.emailAddress,
            onChanged: (value) {},
            // validator: (value) {
            //   //!Error: Pattern pattern => String pattern;
            //   String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            //   RegExp regex = RegExp(pattern);
            //   return (regex.hasMatch(value!)) ? null : '이메일 형식으로 입력해주세요';
            // },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            sunit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
            ),
            textScaleFactor: 1.0,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              Icons.add_circle,
              color: Colors.black45,
            ),
            onPressed: () {
              try {
                int vv = int.parse(cc.text);
                vv++;
                cc.text = vv.toString();
              } catch (E) {}
            },
          ),
        ),
      ],
    ),
  );
}