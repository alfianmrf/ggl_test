import 'dart:async';
import 'dart:io';

import 'package:ggl_test/Barang.dart';
import 'package:ggl_test/Stok.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbName = 'Database.db';
  static final _dbVersion = 2;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initiateDatabase();

  Future<Database> _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onOpen: (db) {}, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE data_barang ("
      "id INTEGER PRIMARY KEY,"
      "kode_barang TEXT,"
      "nama_barang TEXT,"
      "gambar_barang TEXT"
      ")");
    await db.execute(
      "CREATE TABLE data_stok ("
      "id INTEGER PRIMARY KEY,"
      "id_barang INTEGER,"
      "total_barang INTEGER,"
      "jenis_stok TEXT"
      ")");
  }

  Future<int> insert(String name, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(name, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Barang>> getBarang() async {
    final db = await database;
    var res = await db.query('data_barang');
    List<Barang> list = res.isNotEmpty ? res.map((c) => Barang.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Stok>> getStok(int id_barang) async {
    final db = await database;
    var res = await db.query('data_stok', where: '"id_barang" = "$id_barang"');
    List<Stok> list = res.isNotEmpty ? res.map((c) => Stok.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> update(String name, int id, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(name, row, conflictAlgorithm: ConflictAlgorithm.replace, where: '"id" = "$id"');
  }

  Future<int> delete(String name, int id) async {
    Database db = await instance.database;
    return await db.delete(name, where: '"id" = "$id"');
  }

  Future<int> deleteStok(int id) async {
    Database db = await instance.database;
    return await db.delete('data_stok', where: '"id_barang" = "$id"');
  }
}