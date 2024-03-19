import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          button: TextStyle(fontSize: 20, color: Colors.white),
          bodyText1: TextStyle(fontSize: 18, color: Colors.black),
          bodyText2: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmployeePage()),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(fontSize: 20),
          ),
          child: Text('Visualizza dipendente'),
        ),
      ),
    );
  }
}

class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  Future<void> _fetchEmployee(String code) async {
    final response = await http.get(Uri.parse(
        'http://192.168.151.106/server.php?codice=$code'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['stato'] == "OK-1") {
        setState(() {
          _response = 'Nome: ${jsonResponse['nome']}\n'
              'Cognome: ${jsonResponse['cognome']}\n'
              'Reparto: ${jsonResponse['reparto']}';
        });
      } else if (jsonResponse['stato'] == "OK-2") {
        setState(() {
          _response = 'URL valido, codice non esiste';
        });
      } else {
        setState(() {
          _response =
              'Errore durante la richiesta: ${jsonResponse['messaggio']}';
        });
      }
    } else {
      setState(() {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        _response = 'Errore durante la richiesta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizza Dipendente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Codice dipendente'),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final code = _controller.text;
                _fetchEmployee(code);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Invia richiesta'),
            ),
            SizedBox(height: 20),
            Text(
              _response,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
