import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class Functions {
  //menampilkan toast dengan durasi yang lama
  void longtoast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.black54,
        textColor: Colors.white);
  }

  //method untuk pindah halaman dengan animasi geser kiri ke kanan
  backAction(Widget previous, BuildContext context) {
    Navigator.pushReplacement(context,
        PageTransition(type: PageTransitionType.leftToRight, child: previous));
  }
}
