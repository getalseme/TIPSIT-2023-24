import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

import 'models.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Post, Comment]) // Make sure both entities are included here
abstract class MyAppDatabase extends FloorDatabase {
  PostDao get postDao;
  CommentDao get commentDao;
}
