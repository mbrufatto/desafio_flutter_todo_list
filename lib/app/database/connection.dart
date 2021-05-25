import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:todo_list/app/database/migrations/migration_V2.dart';
import 'package:todo_list/app/database/migrations/migration_v1.dart';

class Connection {
  static const VERSION = 1;
  static const DATABASE_NAME = 'TODO_LIST';

  static Connection _intance;
  Database _db;
  final _lock = Lock();

  factory Connection() {
    if (_intance == null) {
      _intance = Connection._();
    }
    return _intance;
  }

  Connection._();

  Future<Database> get instance async => await _openConnection();

  Future<Database> _openConnection() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        if (_db == null) {
          var databasePath = await getDatabasesPath();
          var pathDatabase = join(databasePath, DATABASE_NAME);

          _db = await openDatabase(
            pathDatabase,
            version: VERSION,
            onConfigure: _onConfigure,
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
          );
        }
      });
    }
    return _db;
  }

  void closeConnection() {
    _db?.close();
    _db = null;
  }

  Future<FutureOr<void>> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  FutureOr<void> _onCreate(Database db, int version) {
    var batch = db.batch();
    createV1(batch);
    createV2(batch);
    batch.commit();
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    var batch = db.batch();
    if (oldVersion < 2) {
      upgradeV2(batch);
    }
    if (oldVersion < 3) {
      // upgardeV3(batch)
    }
    batch.commit();
  }
}
