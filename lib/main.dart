import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?key=df69b4ac';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
    hintColor: Colors.amber,
    primaryColor: Colors.amber,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      hintStyle: TextStyle(color: Colors.amber),
    )),
  ));
}

Future<Map> getData() async {
  var response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final britishController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dollar;
  double euro;
  double british;
  double bitcoin;

  void _clearAll() {
    realController.text = '';
    dollarController.text = '';
    euroController.text = '';
    britishController.text = '';
    bitcoinController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    var real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    britishController.text = (real / british).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(5);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    var dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
    britishController.text =
        (dollar * this.dollar / british).toStringAsFixed(2);
    bitcoinController.text =
        (dollar * this.dollar / bitcoin).toStringAsFixed(5);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    var euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
    britishController.text = (euro * this.euro / british).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(5);
  }

  void _britishChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    var british = double.parse(text);
    realController.text = (british * this.british).toStringAsFixed(2);
    dollarController.text =
        (british * this.british / dollar).toStringAsFixed(2);
    euroController.text = (british * this.british / euro).toStringAsFixed(2);
    bitcoinController.text =
        (british * this.british / bitcoin).toStringAsFixed(5);
  }

  void _bitcoinChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    var bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dollarController.text =
      (bitcoin * this.bitcoin / dollar).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
    britishController.text = 
      (bitcoin * this.bitcoin / british).toStringAsFixed(2);
  }

  static const _goldenColor = Color(0xFFFFD700);
  static const _lightColor = Color(0xFFFfcfaf1);

  final kLabelStyle = TextStyle(
    color: _goldenColor, fontWeight: FontWeight.bold, fontSize: 22);

  Widget buildTextField(String label, String prefix,
      TextEditingController changeMoney, Function changed) {
    return TextField(
      controller: changeMoney,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: label,
        labelStyle: kLabelStyle,
        prefixText: prefix),
      style: kLabelStyle,
      onChanged: changed,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightColor,
      appBar: AppBar(
        title: Text('Currency Converter',
          style: TextStyle(color: _lightColor, fontSize: 24)),
        backgroundColor: _goldenColor,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: _lightColor, size: 24),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text('Loading API Data...', style: kLabelStyle));
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error Loading Data...', style: kLabelStyle));
                } else {
                  dollar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro   = snapshot.data['results']['currencies']['EUR']['buy'];
                  british= snapshot.data['results']['currencies']['GBP']['buy'];
                  bitcoin= snapshot.data['results']['currencies']['BTC']['buy'];
                    return SingleChildScrollView(
                      child: Padding(
                      padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(Icons.monetization_on,
                              size: 120.0, color: _goldenColor),
                            Divider(
                              color: _goldenColor,
                              thickness: 2.5,
                              indent: 60,
                              endIndent: 60),
                            Divider(),
                            buildTextField(
                              'Real', 'R\$ ', realController, _realChanged),
                            Divider(),
                            buildTextField(
                              'Dollar', '\$ ', dollarController,
                              _dollarChanged),
                            Divider(),
                            buildTextField(
                              'Euro', '€ ', euroController, _euroChanged),
                            Divider(),
                            buildTextField(
                              'Pound Sterling', '£ ', 
                                britishController, _britishChanged),
                            Divider(),
                            buildTextField(
                              'Bitcoin', '₿ ', bitcoinController,
                                _bitcoinChanged),
                          ],
                        ),
                      )
                    );
                }
          }
        }
      )
    );
  }
}
