// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constanta.dart';
import 'functions.dart';
import 'login.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  State<RegistrasiPage> createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  double widthScreen = 0.0;

  String idDesa = '';

  bool passwordVisible = false, loading = false;

  List<dynamic> listDesa = [];

  TextEditingController namaCtrl = TextEditingController();
  TextEditingController desaCtrl = TextEditingController();
  TextEditingController alamatCtrl = TextEditingController();
  TextEditingController notelpCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    getDesa();
    setState(() {
      passwordVisible = false;
    });
  }

  //method untuk login dengan memanggil api
  Future<void> getDesa() async {
    try {
      final response = await http
          .get(Uri.parse("${Constanta.baseUrl}/api.php?do=desa"))
          .timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      // print(jsonData);
      if (!error) {
        setState(() {
          listDesa = jsonData['desa'];
        });
      } else {
        Functions().longtoast(jsonData['message'].toString());
        listDesa = [];
      }
    } on TimeoutException {
      Functions().longtoast(Constanta.er_server);
      Functions().backAction(const LoginPage(), context);
    } on SocketException {
      // print("Tidak Ada Koneksi Internet");
      Functions().longtoast(Constanta.er_internet);
    } on HttpException {
      // print("Couldn't find the post");
      Functions().longtoast(Constanta.er_post);
    } on FormatException {
      // print("Bad response format");
      Functions().longtoast(Constanta.er_format);
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> showListDesa() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text("Daftar Desa",
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: (listDesa.length * 20) + 100,
                child: ListView.builder(
                    itemCount: listDesa.length,
                    itemBuilder: (_, index) {
                      final x = listDesa[index];
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              desaCtrl.text = x['nama_desa'];
                              idDesa = x['id_desa'];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(x['nama_desa'])));
                    })));
      },
    );
  }

  daftarAkun() async {
    try {
      final response = await http
          .post(Uri.parse("${Constanta.baseUrl}/api.php?do=registrasi"), body: {
        "id_desa": idDesa.toString(),
        "nama_lengkap": namaCtrl.text,
        "alamat": alamatCtrl.text,
        "no_telp": notelpCtrl.text,
        "email": emailCtrl.text,
        "username": usernameCtrl.text,
        "password": passwordCtrl.text
      }).timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      if (!error) {
        Functions().longtoast(jsonData['message'].toString());
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        Functions().longtoast(jsonData['message'].toString());
      }
    } on TimeoutException {
      Functions().longtoast(Constanta.er_server);
    } on SocketException {
      // print("Tidak Ada Koneksi Internet");
      Functions().longtoast(Constanta.er_internet);
    } on HttpException {
      // print("Couldn't find the post");
      Functions().longtoast(Constanta.er_post);
    } on FormatException {
      // print("Bad response format");
      Functions().longtoast(Constanta.er_format);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    widthScreen = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () => Functions().backAction(const LoginPage(), context),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  padding: const EdgeInsets.only(bottom: 20, left: 15),
                  alignment: AlignmentDirectional.bottomCenter,
                  decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0))),
                  child: const Text(
                    "DAFTAR AKUN",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: namaCtrl,
                          decoration: InputDecoration(
                            hintText: "Nama Lengkap",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: true,
                          controller: desaCtrl,
                          decoration: InputDecoration(
                            hintText: "Pilih Desa",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            suffixIcon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                          onTap: () => showListDesa(),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: alamatCtrl,
                          decoration: InputDecoration(
                            hintText: "Alamat",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          controller: notelpCtrl,
                          decoration: InputDecoration(
                            hintText: "No. Telp",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          keyboardType: TextInputType.emailAddress,
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: usernameCtrl,
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(5.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.green),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(width: 1, color: Colors.red),
                            ),
                          ),
                          onTap: () {},
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          controller: passwordCtrl,
                          keyboardType: TextInputType.text,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                              hintText: "Password",
                              hintStyle: const TextStyle(color: Colors.black),
                              contentPadding: const EdgeInsets.all(5.0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.green),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                  color: Colors.grey,
                                  icon: Icon(
                                    !passwordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  ))),
                          onTap: () {},
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                    child: loading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: () => daftarAkun(),
                            child: Container(
                              height: 35,
                              width: widthScreen > 610
                                  ? widthScreen / 5.7 > 200
                                      ? widthScreen / 5.7
                                      : widthScreen - 50.0
                                  : widthScreen - 50.0,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25))),
                              child: const Text("Daftar",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text("Sudah punya Akun?",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text("Login",
                            style: TextStyle(fontSize: 14, color: Colors.blue)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
