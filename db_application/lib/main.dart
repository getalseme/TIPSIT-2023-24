import 'package:flutter/material.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

// Entities
@entity
class Artista {
  @PrimaryKey()
  final int id;
  final String nome;

  Artista(this.id, this.nome);
}

@entity
class Brano {
  @PrimaryKey()
  final int id;
  final int idArtista;
  final String titolo;
  final String durata;

  Brano(this.id, this.idArtista, this.titolo, this.durata);
}

// Database
@Database(version: 1, entities: [Artista, Brano])
abstract class MyAppDatabase extends FloorDatabase {
  ArtistaDao get artistaDao;
  BranoDao get branoDao;
}

// DAOs
@dao
abstract class ArtistaDao {
  @Query('SELECT * FROM Artista')
  Future<List<Artista>> findAllArtists();

  @Insert()
  Future<void> insertArtista(Artista artista);
}

@dao
abstract class BranoDao {
  @Query('SELECT * FROM Brano')
  Future<List<Brano>> findAllBrani();

  @Insert()
  Future<void> insertBrano(Brano brano);
}

// Database Provider
class DatabaseProvider {
  static late MyAppDatabase _database;

  static Future<void> initDatabase() async {
    final database = await $FloorMyAppDatabase
        .databaseBuilder('my_database.db')
        .build();
    _database = database;
  }

  static MyAppDatabase get database {
    return _database;
  }
}

// Main Function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseProvider.initDatabase();
  runApp(MyApp());
}

// App Widget
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Artista> _artisti = [];
  List<Brano> _brani = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final artistaDao = DatabaseProvider.database.artistaDao;
    final branoDao = DatabaseProvider.database.branoDao;

    _artisti = await artistaDao.findAllArtists();
    _brani = await branoDao.findAllBrani();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Database App'),
        ),
        body: ListView.builder(
          itemCount: _artisti.length,
          itemBuilder: (context, index) {
            final artista = _artisti[index];
            final braniArtista =
                _brani.where((brano) => brano.idArtista == artista.id).toList();
            return ListTile(
              title: Text(artista.nome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: braniArtista.map((brano) => Text(brano.titolo)).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
