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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excuser',
      home: MyHomePage(title: 'Excuser Home'),
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

  List<Map> _excuses = [];
  Map excuse = {};
  Map _translatedTexts = {};

  Future<void> _getExcuse({String n = "3"}) async {
    // https://excuser.herokuapp.com/
    _excuses = [];
    _translatedTexts = {};

    final response = await get(
      Uri(
        host: "excuser.herokuapp.com",
        scheme: "https",
        pathSegments: ["v1", "excuse", n],
      ),
    );

    // JSON =>
    _excuses = (jsonDecode(response.body) as List).cast();

    setState(() {});
  }

  @override
  void initState() {
    _getExcuse();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.yellow[700],
        actions: [
          IconButton(
            onPressed: _getExcuse,
            icon: const Icon(Icons.refresh_sharp),
            hoverColor: Colors.yellow[800],
          ),
        ],
      ),
      body: _excuses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                for (final excuse in _excuses)
                  SizedBox(
                    height: 80,
                    child: Card(
                      child: ListView(children: [
                        SizedBox(height: 10),
                        ListTile(
                          //Text("Category: ${excuse['category']}"),
                          leading: const Icon(Icons.list),
                          title: Center(
                            child: Text(
                              "${excuse['excuse']}",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          subtitle: Center(
                            child: Text(
                              (_translatedTexts.isNotEmpty)
                                  ? (_translatedTexts[excuse["id"]] ??
                                      "Çeviri yapilamadi.")
                                  : "",
                              style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  color: Colors
                                      .blue //Theme.of(context).textTheme.bodyText1,
                                  ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[900],
        onPressed: () {
          if (_excuses.isNotEmpty) {
            for (final excuse in _excuses) {
              translator.translate(excuse['excuse'], to: 'tr').then((ceviri) {
                _translatedTexts[excuse["id"]] = ceviri.text;
                setState(() {});
              });
            }
          }
        },
        tooltip: 'Translate',
        child: const Icon(Icons.g_translate_sharp),
      ),
    );
  }
}
