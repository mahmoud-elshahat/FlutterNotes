import 'package:notes/models/Note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "notes_db.db";
  static final _databaseVersion = 1;

  static final table = 'notes';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnInfo = 'info';
  static final columnDate = 'date';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTitle TEXT ,
            $columnInfo TEXT NOT NULL,
            $columnDate TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Note note) async {
    Database db = await instance.database;
    return await db.insert(table, {
      columnTitle: note.title,
      columnInfo: note.info,
      columnDate: note.date
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }


  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Note note) async {
    Database db = await instance.database;
    int id = note.toMap()['id'];
    return await db.update(table, note.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }


}
