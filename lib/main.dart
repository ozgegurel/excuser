import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excuser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Excuser Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final translator = GoogleTranslator();

  List<Map> _mazeretler = [];
  Map mazeret = {};
  Map _translatedTexts = {};

  Future<void> _veriGetir() async {
    // Daha detaylı kullanım için => https://excuser.herokuapp.com/
    _mazeretler = [];
    _translatedTexts = {};

    final cevap = await get(
      Uri(
        host: "excuser.herokuapp.com",
        scheme: "https",
        pathSegments: ["v1", "excuse", "3"],
      ),
    );

    // JSON =>
    _mazeretler = (jsonDecode(cevap.body) as List).cast();

    setState(() {});
  }

  @override
  void initState() {
    _veriGetir();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _veriGetir,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _mazeretler.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                for (final mazeret in _mazeretler)
                  Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category: ${mazeret['category']}"),
                                Text(
                                  "${mazeret['excuse']}",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_translatedTexts.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                _translatedTexts[mazeret["id"]] ??
                                    "Çeviri yapilamadi.",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_mazeretler.isNotEmpty) {
            for (final mazeret in _mazeretler) {
              translator.translate(mazeret['excuse'], to: 'tr').then((ceviri) {
                _translatedTexts[mazeret["id"]] = ceviri.text;
                setState(() {});
              });
            }
          }
        },
        tooltip: 'Translate',
        child: const Icon(Icons.translate),
      ),
    );
  }
}
