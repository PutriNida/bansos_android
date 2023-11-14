// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bansos_android/home.dart';
import 'package:bansos_android/registrasi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'functions.dart';
import 'constanta.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double widthScreen = 0.0;

  bool passwordVisible = false, loading = false, logedIn = false;

  TextEditingController usernameCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      passwordVisible = false;
    });
  }

  //method untuk login dengan memanggil api
  Future aksilogin() async {
    try {
      final response = await http
          .post(Uri.parse("${Constanta.baseUrl}/api.php?do=login"), body: {
        "username": usernameCtrl.text,
        "password": passwordCtrl.text
      }).timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      if (!error) {
        print(jsonData);
        setState(() {
          logedIn = true;
          savePref(jsonData['user']);
        });
        Functions().longtoast("Login Berhasil!");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
        Functions().longtoast(jsonData['message'].toString());
        loading = false;
      }
    } on TimeoutException {
      Functions().longtoast(Constanta.er_server);
      Functions().backAction(const LoginPage(), context);
    } on SocketException {
      // print("Tidak Ada Koneksi Internet");
      Functions().longtoast(Constanta.er_internet);
      loading = false;
    } on HttpException {
      // print("Couldn't find the post");
      Functions().longtoast(Constanta.er_post);
      loading = false;
    } on FormatException {
      // print("Bad response format");
      Functions().longtoast(Constanta.er_format);
      loading = false;
    }
  }

  //aksi setelah login berhasil yaitu menyimpan beberapa variabel ke penyimpanan lokal/session/shared preferences
  savePref(dynamic data) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setBool("logedIn", logedIn);
      preferences.setString("username", data["username"] ?? '');
      preferences.setString("nama", data["nama_lengkap"] ?? "Administrator");
      preferences.setString("id_desa", data["id_desa"] ?? '');
      preferences.setString("desa", data["desa"] ?? '');
      preferences.setString("id_akun", data["id_akun"] ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    widthScreen = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () => exit(0),
        child: Scaffold(
            body: SingleChildScrollView(
          child: SizedBox(
            // padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height * 0.3,
                    padding: const EdgeInsets.fromLTRB(15, 50, 15, 10),
                    decoration: const BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(50.0),
                            bottomLeft: Radius.circular(50.0))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Image.asset(
                              "assets/logo_rohul.png",
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text('Pengajuan Dana Bantuan',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text('KECAMATAN KEPENUHAN',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('- LOGIN -',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)))
                        ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        width: widthScreen > 610
                            ? widthScreen / 5.7 > 200
                                ? widthScreen / 5.7
                                : widthScreen - 50.0
                            : widthScreen - 50.0,
                        child: TextFormField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
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
                        child: TextFormField(
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
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                    child: GestureDetector(
                        onTap: () => aksilogin(),
                        child: Container(
                          height: 35,
                          width: widthScreen > 610
                              ? widthScreen / 5.7 > 200
                                  ? widthScreen / 5.7
                                  : widthScreen - 50.0
                              : widthScreen - 50.0,
                          decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Login",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white)
                            ],
                          ),
                        ))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text("Belum punya Akun?",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegistrasiPage()),
                          );
                        },
                        child: const Text("Buat Akun",
                            style: TextStyle(fontSize: 14, color: Colors.blue)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
