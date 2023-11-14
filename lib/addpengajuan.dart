// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'constanta.dart';
import 'functions.dart';
import 'home.dart';

class AddPengajuanPage extends StatefulWidget {
  const AddPengajuanPage({super.key});

  @override
  State<AddPengajuanPage> createState() => _AddPengajuanPageState();
}

class _AddPengajuanPageState extends State<AddPengajuanPage> {
  TextEditingController nominalCtrl = TextEditingController();
  TextEditingController keperluanCtrl = TextEditingController();
  TextEditingController detailCtrl = TextEditingController();

  int nominal = 0;

  bool loading = false;

  final CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(
    locale: 'id',
    decimalDigits: 0,
    symbol: 'Rp.',
  );

  @override
  void initState() {
    super.initState();
    nominalCtrl.addListener(() {
      if (nominalCtrl.text.isNotEmpty) {
        String moveRp = nominalCtrl.text.replaceAll('Rp.', '');
        String pengajuan = moveRp.replaceAll('.', '');
        setState(() {
          nominal = int.parse(pengajuan);
          print(nominal);
        });
      }
    });
  }

  savePengajuan() async {
    try {
      final response = await http
          .post(Uri.parse("${Constanta.baseUrl}/api.php?do=add"), body: {
        "id_akun": Constanta.dataUser['id_akun'],
        "nominal": nominal.toString(),
        "keperluan": keperluanCtrl.text,
        "detail": detailCtrl.text
      }).timeout(const Duration(seconds: 30));
      final jsonData = jsonDecode(response.body);
      bool error = jsonData['error'];
      if (!error) {
        Functions().longtoast(jsonData['message'].toString());
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
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
    return WillPopScope(
        onWillPop: () => Functions().backAction(const HomePage(), context),
        child: Scaffold(
            body: Column(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                padding: const EdgeInsets.only(bottom: 20, left: 15),
                alignment: AlignmentDirectional.bottomStart,
                decoration: const BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                      child: GestureDetector(
                          onTap: () =>
                              Functions().backAction(const HomePage(), context),
                          child: const Icon(Icons.arrow_circle_left_outlined,
                              color: Colors.white)),
                    ),
                    const Text(
                      "Pengajuan Baru",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),
            SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    child: SizedBox(
                        height: 40,
                        child: TextField(
                          inputFormatters: <TextInputFormatter>[formatter],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: nominalCtrl,
                          decoration: InputDecoration(
                            hintText: "Nominal Pengajuan",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(10.0),
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
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: keperluanCtrl,
                          decoration: InputDecoration(
                            hintText: "Keperluan",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding: const EdgeInsets.all(10.0),
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
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                          enabled: true,
                          readOnly: false,
                          controller: detailCtrl,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Detail",
                            hintStyle: const TextStyle(color: Colors.black),
                            contentPadding:
                                const EdgeInsets.fromLTRB(10.0, 15.0, 5.0, 0.0),
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
                GestureDetector(
                    onTap: () {
                      setState(() {
                        loading = true;
                      });
                      savePengajuan();
                    },
                    child: loading
                        ? const CircularProgressIndicator()
                        : Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 50,
                            padding: const EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15.0)),
                            child: const Center(
                                child: Text("Simpan",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))))),
              ]),
            ))
          ],
        )));
  }
}
