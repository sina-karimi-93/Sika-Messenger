import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as db;

class DbHandler {
  /*
  This class contains several static method for interacting
  to local database. Desired database is sqflite.
  methods:
    database
    insert_record
    get_record
    delete_record
  */

  static Future<db.Database> _getDatabase() async {
    /*
    This method create and get the local database which is a sqflite.
    For CRUD operations, other methods like insert_record, get_record,...
    needs this database.
    */
    final dbPath = await db.getDatabasesPath();
    db.Database database = await db.openDatabase(
      path.join(dbPath, "sika_messenger.db"),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE users(localId INTEGER PRIMARY KEY,serverId Text, name TEXT, email TEXT, password TEXT, phoneNumber TEXT)");
      },
      version: 1,
    );
    return database;
  }

  static Future<int> insertRecord({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    /*
    This static method gets table name and data and insert them
    into database. After inserting, it will return the id of the
    inserted data.

    args:
      table
      data
    */
    final database = await _getDatabase();
    final int localId = await database.insert(table, data,
        conflictAlgorithm: db.ConflictAlgorithm.replace);
    return localId;
  }

  static Future<List<Map<String, dynamic>>> getRecord(
      {required String table}) async {
    /*
    This method gets a table name and return all data from that
    table.

    args:
      table
    */
    final database = await _getDatabase();
    final records = await database.query(table);
    return records;
  }

  static Future<Map<String, dynamic>> getUser(int localId) async {
    /*
    This method gets a table name and userId and return a user that
    matches.
    
    args:
      table
      userId
    */
    final database = await _getDatabase();
    final user = await database
        .query("users", where: "localId = ?", whereArgs: [localId]);
    if (user.isNotEmpty) {
      return user.first;
    }
    return {};
  }

  static Future<int> deleteUser(int userId) async {
    /*
    This method is for removing a user from database. It gets table name
    and id, then remove the user with that id.

    args:
      table
      userId
    */
    final database = await _getDatabase();
    int result = await database
        .delete("users", where: "localId = ?", whereArgs: [userId]);
    return result;
  }

  static Future<Map<String, dynamic>> isUserExists(String serverId) async {
    /*
    This method checks whether a user exists in local database or not.
    It checks by user serverId.

    args:
      serverId
    */
    final database = await _getDatabase();
    final user = await database
        .query("users", where: "serverId = ?", whereArgs: [serverId]);
    if (user.isNotEmpty) {
      return user.first;
    }
    return {};
  }
}
