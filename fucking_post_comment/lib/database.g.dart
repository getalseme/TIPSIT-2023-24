// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorMyAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyAppDatabaseBuilder databaseBuilder(String name) =>
      _$MyAppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$MyAppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$MyAppDatabaseBuilder(null);
}

class _$MyAppDatabaseBuilder {
  _$MyAppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$MyAppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$MyAppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<MyAppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$MyAppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$MyAppDatabase extends MyAppDatabase {
  _$MyAppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PostDao? _postDaoInstance;

  CommentDao? _commentDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Post` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `body` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Comment` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `text` TEXT NOT NULL, `postId` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PostDao get postDao {
    return _postDaoInstance ??= _$PostDao(database, changeListener);
  }

  @override
  CommentDao get commentDao {
    return _commentDaoInstance ??= _$CommentDao(database, changeListener);
  }
}

class _$PostDao extends PostDao {
  _$PostDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _postInsertionAdapter = InsertionAdapter(
            database,
            'Post',
            (Post item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body
                }),
        _postDeletionAdapter = DeletionAdapter(
            database,
            'Post',
            ['id'],
            (Post item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Post> _postInsertionAdapter;

  final DeletionAdapter<Post> _postDeletionAdapter;

  @override
  Future<List<Post>> findAllPosts() async {
    return _queryAdapter.queryList('SELECT * FROM Post',
        mapper: (Map<String, Object?> row) => Post(
            row['id'] as int?, row['title'] as String, row['body'] as String));
  }

  @override
  Future<void> insertPost(Post post) async {
    await _postInsertionAdapter.insert(post, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePost(Post post) async {
    await _postDeletionAdapter.delete(post);
  }
}

class _$CommentDao extends CommentDao {
  _$CommentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _commentInsertionAdapter = InsertionAdapter(
            database,
            'Comment',
            (Comment item) => <String, Object?>{
                  'id': item.id,
                  'text': item.text,
                  'postId': item.postId
                }),
        _commentDeletionAdapter = DeletionAdapter(
            database,
            'Comment',
            ['id'],
            (Comment item) => <String, Object?>{
                  'id': item.id,
                  'text': item.text,
                  'postId': item.postId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Comment> _commentInsertionAdapter;

  final DeletionAdapter<Comment> _commentDeletionAdapter;

  @override
  Future<List<Comment>> findCommentsForPost(int postId) async {
    return _queryAdapter.queryList('SELECT * FROM Comment WHERE postId = ?1',
        mapper: (Map<String, Object?> row) => Comment(
            row['id'] as int?, row['text'] as String, row['postId'] as int),
        arguments: [postId]);
  }

  @override
  Future<void> insertComment(Comment comment) async {
    await _commentInsertionAdapter.insert(comment, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteComment(Comment comment) async {
    await _commentDeletionAdapter.delete(comment);
  }
}
