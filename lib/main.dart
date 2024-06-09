import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const request = 'https://api.hgbrasil.com/finance?key=df69b4ac';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ThemeData(
        useMaterial3: true,
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  try {
    final response = await Dio().get(request);
    return response.data;
  } catch (e, s) {
    debugPrint('Error Loading Data: $e, $s');
    return Future.error('Error Loading Data...');
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  static const goldenColor = Color(0xFFFFD700);
  static const lightColor = Color(0xffF5F5F5);

  static const kLabelStyle = TextStyle(
    color: goldenColor,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  );

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final britishController = TextEditingController();
  final bitcoinController = TextEditingController();

  static const lightColor = Home.lightColor;
  static const kLabelStyle = Home.kLabelStyle;
  static const goldenColor = Home.goldenColor;

  late Future<Map> data;

  double dollar = 0.0;
  double euro = 0.0;
  double british = 0.0;
  double bitcoin = 0.0;

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

  @override
  void initState() {
    super.initState();
    data = getData();
  }

  @override
  void dispose() {
    realController.dispose();
    dollarController.dispose();
    euroController.dispose();
    britishController.dispose();
    bitcoinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(color: lightColor, fontSize: 24),
        ),
        backgroundColor: goldenColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.refresh,
            color: lightColor,
            size: 24,
          ),
          onPressed: () async {
            setState(() {
              data = getData();
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: lightColor,
              size: 24,
            ),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: FutureBuilder<Map>(
        future: data,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text('Loading API Data...', style: kLabelStyle),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error Loading Data...', style: kLabelStyle),
                );
              } else {
                double getCurrencies(String currency) =>
                    (snapshot.data?['results']['currencies'][currency]
                        ['buy']) ??
                    0.0;

                dollar = getCurrencies('USD');
                euro = getCurrencies('EUR');
                british = getCurrencies('GBP');
                bitcoin = getCurrencies('BTC');

                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(
                          Icons.monetization_on,
                          size: 120.0,
                          color: goldenColor,
                        ),
                        const Divider(
                          color: goldenColor,
                          thickness: 2.5,
                          indent: 60,
                          endIndent: 60,
                        ),
                        const SizedBox(height: 24),
                        AppTextFormField(
                          label: 'Real',
                          prefix: 'R\$ ',
                          controller: realController,
                          onChanged: _realChanged,
                        ),
                        AppTextFormField(
                          label: 'Dollar',
                          prefix: '\$ ',
                          controller: dollarController,
                          onChanged: _dollarChanged,
                        ),
                        AppTextFormField(
                          label: 'Euro',
                          prefix: '€ ',
                          controller: euroController,
                          onChanged: _euroChanged,
                        ),
                        AppTextFormField(
                          label: 'Pound Sterling',
                          prefix: '£ ',
                          controller: britishController,
                          onChanged: _britishChanged,
                        ),
                        AppTextFormField(
                          label: 'Bitcoin',
                          prefix: '₿ ',
                          controller: bitcoinController,
                          onChanged: _bitcoinChanged,
                        ),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.label,
    required this.prefix,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String prefix;
  final TextEditingController controller;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: Home.kLabelStyle,
            prefixText: prefix,
          ),
          style: Home.kLabelStyle,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
