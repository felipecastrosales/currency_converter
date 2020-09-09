import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=df69b4ac';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
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
  http.Response response = await http.get(request);
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
  final bitcoinController = TextEditingController();

  double dollar;
  double euro;
  double bitcoin;

  void _clearAll() {
    realController.text = '';
    dollarController.text = '';
    euroController.text = '';
    bitcoinController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(5);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
    bitcoinController.text = (dollar * this.euro / bitcoin).toStringAsFixed(5);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(5);
  }

  void _bitcoinChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
    dollarController.text =
        (bitcoin * this.bitcoin / dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('\$ Conversor de Moedas \$',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
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
                      child: Text(
                    'Carregando Dados...',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Erro ao carregar dados...',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dollar =
                    snapshot.data['results']['currencies']['USD']['buy'];
                    euro =
                    snapshot.data['results']['currencies']['EUR']['buy'];
                    bitcoin =
                    snapshot.data['results']['currencies']['BTC']['buy'];
                    return SingleChildScrollView(
                        child: Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextField(
                              'Reais', 'R\$', realController, _realChanged),
                          Divider(),
                          buildTextField(
                              'Dólar', '\$', dollarController, _dollarChanged),
                          Divider(),
                          buildTextField(
                              'Euros', '€', euroController, _euroChanged),
                          Divider(),
                          buildTextField('Bitcoin', '₿', bitcoinController,
                              _bitcoinChanged),
                        ],
                      ),
                    ));
                  }
              }
            }));
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController changeMoney, Function changed) {
  return TextField(
    controller: changeMoney,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 22.0,
    ),
    onChanged: changed,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
