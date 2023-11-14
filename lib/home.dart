// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'addpengajuan.dart';
import 'constanta.dart';
import 'functions.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool logedIn = false, loading = true, loadPengajuan = true;
  bool showAll = false,
      showProses = false,
      showSetuju = false,
      showTolak = false;
  int all = 0, proses = 0, setuju = 0, tolak = 0, idStatus = 0;
  List listPengajuan = [];
  final idr = NumberFormat.currency(locale: 'id', symbol: 'Rp ');

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  //memastikan status login di lokal perangkat
  checkLogin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    logedIn = preferences.getBool('logedIn') ?? false;
    Future.delayed(
        const Duration(seconds: 3),
        () => logedIn
            ? setData()
            : Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: const LoginPage())));
  }

  setData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      Constanta.dataUser = {
        "username": preferences.getString("username") ?? '',
        "nama": preferences.getString("nama") ?? "Administrator",
        "id_desa": preferences.getString("id_desa") ?? '',
        "desa": preferences.getString("desa") ?? '',
        "id_akun": preferences.getString("id_akun") ?? '',
      };
      showAll = true;
    });
    listPengajuan = await getPengajuan();
    getJumPengajuan();
    // print(Constanta.dataUser);
  }

  //method untuk login dengan memanggil api
  Future getJumPengajuan() async {
    try {
      final response = await http
          .get(Uri.parse(
              "${Constanta.baseUrl}/api.php?do=count&id_akun=${Constanta.dataUser['id_akun']}"))
          .timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      // print(jsonData);
      if (!error) {
        setState(() {
          all = jsonData['all'];
          proses = jsonData['proses'];
          setuju = jsonData['setuju'];
          tolak = jsonData['tolak'];
        });
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
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
    loading = false;
  }

  //method untuk login dengan memanggil api
  Future<List<dynamic>> getPengajuan() async {
    getJumPengajuan();
    loadPengajuan = true;
    List listTemp = [];
    try {
      final response = await http
          .get(Uri.parse(
              "${Constanta.baseUrl}/api.php?do=select&id_akun=${Constanta.dataUser['id_akun']}&id_status=$idStatus"))
          .timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      // print(jsonData);
      if (!error) {
        if (jsonData['pengajuan'] == null) {
          listTemp = [];
        } else {
          setState(() {
            listTemp = jsonData['pengajuan'];
          });
        }
      } else {
        Functions().longtoast(jsonData['message'].toString());
        listTemp = [];
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
      loadPengajuan = false;
    });
    return listTemp;
  }

  Future<void> _showMyDialog(dynamic data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              data['id_status'] == "3" ? "Nominal Disetujui" : "Alasan Ditolak",
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          content: Text(
            data['id_status'] == "3"
                ? idr.format(int.parse(data['nominal_setuju']))
                : data['alasan_ditolak'],
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.green),
                  alignment: Alignment.center,
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogDiambil(dynamic data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Diambil",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("Tanggal Ambil",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                Text(data['tgl_ambil'],
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
                const Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text("Oleh",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))),
                Text(data['diambil_oleh'],
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
                const Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text("Nominal Diambil",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))),
                Text(idr.format(int.parse(data['nominal_ambil'])),
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
                const Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text("Petugas",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold))),
                Text(data['diserahkan_oleh'],
                    style: const TextStyle(fontSize: 15, color: Colors.black)),
              ]),
          actions: <Widget>[
            TextButton(
              child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.green),
                  alignment: Alignment.center,
                  child:
                      const Text('OK', style: TextStyle(color: Colors.white))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop, child: const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => exit(0),
        child: Scaffold(
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
                      SingleChildScrollView(
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.3,
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                  color: Colors.lightGreen,
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(50.0),
                                      bottomLeft: Radius.circular(50.0))),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: Image.asset(
                                          "assets/logo_rohul.png",
                                          fit: BoxFit.contain,
                                          width: 60,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            Constanta.dataUser["nama"] ??
                                                "Administrator",
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            Constanta.dataUser["desa"] ?? "-",
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          onPressed: () => logout(),
                                          icon: const Icon(
                                            Icons.exit_to_app_rounded,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Text(
                                          'Pengajuan',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      idStatus = 0;
                                                      showAll = true;
                                                      showProses = false;
                                                      showSetuju = false;
                                                      showTolak = false;
                                                    });
                                                    listPengajuan =
                                                        await getPengajuan();
                                                  },
                                                  child: Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.8) /
                                                            4,
                                                    // height:
                                                    //     MediaQuery.of(context).size.height *
                                                    //         0.12,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(15),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      15)),
                                                      color: showAll
                                                          ? Colors.blueGrey
                                                          : Colors.blueAccent,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text('Total',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        Text(all.toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    ),
                                                  )),
                                              GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      idStatus = 2;
                                                      showAll = false;
                                                      showProses = true;
                                                      showSetuju = false;
                                                      showTolak = false;
                                                    });
                                                    listPengajuan =
                                                        await getPengajuan();
                                                  },
                                                  child: Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.8) /
                                                            4,
                                                    // height:
                                                    //     MediaQuery.of(context).size.height *
                                                    //         0.12,
                                                    color: showProses
                                                        ? Colors.blueGrey
                                                        : Colors.amberAccent,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text('Diproses',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        Text(proses.toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    ),
                                                  )),
                                              GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      idStatus = 3;
                                                      showAll = false;
                                                      showProses = false;
                                                      showSetuju = true;
                                                      showTolak = false;
                                                    });
                                                    listPengajuan =
                                                        await getPengajuan();
                                                  },
                                                  child: Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.8) /
                                                            4,
                                                    // height:
                                                    //     MediaQuery.of(context).size.height *
                                                    //         0.12,
                                                    color: showSetuju
                                                        ? Colors.blueGrey
                                                        : Colors.greenAccent,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text('Disetujui',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        Text(setuju.toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    ),
                                                  )),
                                              GestureDetector(
                                                  onTap: () async {
                                                    setState(() {
                                                      idStatus = 4;
                                                      showAll = false;
                                                      showProses = false;
                                                      showSetuju = false;
                                                      showTolak = true;
                                                    });
                                                    listPengajuan =
                                                        await getPengajuan();
                                                  },
                                                  child: Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.8) /
                                                            4,
                                                    // height:
                                                    //     MediaQuery.of(context).size.height *
                                                    //         0.12,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topRight: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                      color: showTolak
                                                          ? Colors.blueGrey
                                                          : Colors.redAccent,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text('Ditolak',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors
                                                                    .white)),
                                                        Text(tolak.toString(),
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ],
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () => Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .bottomToTop,
                                                    child:
                                                        const AddPengajuanPage())),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0)),
                                                child: const Center(
                                                  child: Text(
                                                      "Tambah Pengajuan",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )))
                                      ],
                                    ),
                                  ),
                                ],
                              ))),
                      SingleChildScrollView(
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.68,
                              padding: const EdgeInsets.all(10),
                              child: loadPengajuan
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : listPengajuan.isEmpty
                                      ? const Center(child: Text("Data Kosong"))
                                      : ListView.builder(
                                          itemCount: listPengajuan.length,
                                          itemBuilder: (_, index) {
                                            final x = listPengajuan[index];
                                            return Card(
                                              child: Column(
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                "Tanggal Pengajuan",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          const Text(" : "),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                x['tgl_pengajuan'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                        ],
                                                      )),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                "Keperluan",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          const Text(" : "),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                x['keperluan'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                        ],
                                                      )),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                "Nominal Pengajuan",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                          const Text(" : "),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                idr.format(
                                                                    int.parse(x[
                                                                        'nominal'])),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                        ],
                                                      )),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Expanded(
                                                          flex: 2,
                                                          child:
                                                              GestureDetector(
                                                                  onTap: x['id_status'] ==
                                                                              '1' ||
                                                                          x['id_status'] ==
                                                                              '2'
                                                                      ? null
                                                                      : () =>
                                                                          _showMyDialog(
                                                                              x),
                                                                  child: Container(
                                                                      height: 30,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomRight: Radius.circular(x['id_status'] != '3'
                                                                                ? 10.0
                                                                                : 0),
                                                                            bottomLeft:
                                                                                const Radius.circular(10.0)),
                                                                        color: x['id_status'] ==
                                                                                '1'
                                                                            ? Colors.grey
                                                                            : x['id_status'] == '2'
                                                                                ? Colors.amberAccent
                                                                                : x['id_status'] == '3'
                                                                                    ? Colors.greenAccent
                                                                                    : Colors.redAccent,
                                                                      ),
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        // x['id_status'].toString(),
                                                                        x['id_status'] ==
                                                                                '2'
                                                                            ? "Diproses"
                                                                            : x['id_status'] == '3'
                                                                                ? "Disetujui"
                                                                                : x['id_status'] == '4'
                                                                                    ? "Ditolak"
                                                                                    : "Baru",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      )))),
                                                      x['id_ambil'] == null
                                                          ? Container()
                                                          : Expanded(
                                                              flex: 2,
                                                              child: GestureDetector(
                                                                  onTap: () => _showMyDialogDiambil(x),
                                                                  child: Container(
                                                                      height: 30,
                                                                      decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomRight: Radius.circular(10.0)), color: Colors.orangeAccent),
                                                                      alignment: Alignment.center,
                                                                      child: Text(
                                                                        // x['id_status'].toString(),
                                                                        x['id_ambil'] ==
                                                                                '1'
                                                                            ? "Belum Diambil"
                                                                            : "Sudah Diambil",
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      )))),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          })))
                    ],
                  )));
  }
}
