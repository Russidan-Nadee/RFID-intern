import 'dart:io';
import 'package:rfid_project/core/constants/app_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "assetsdb.db");

    bool exists = await File(path).exists();
    if (!exists) {
      ByteData data = await rootBundle.load('assets/assetsdb.db');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    var dbClient = await openDatabase(path);

    // ตรวจสอบว่ามีตาราง categories หรือยัง
    var tables = await dbClient.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table" AND name="categories"',
    );
    if (tables.isEmpty) {
      // สร้างตาราง categories
      await dbClient.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
        )
      ''');

      // เพิ่มค่าเริ่มต้นจาก AppConstants
      for (String category in AppConstants.defaultAssetCategories) {
        await dbClient.insert('categories', {'name': category});
      }
    }

    // ตรวจสอบว่ามีตาราง departments หรือยัง
    tables = await dbClient.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table" AND name="departments"',
    );
    if (tables.isEmpty) {
      // สร้างตาราง departments
      await dbClient.execute('''
        CREATE TABLE departments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
        )
      ''');

      // เพิ่มค่าเริ่มต้นจาก AppConstants
      for (String department in AppConstants.defaultDepartments) {
        await dbClient.insert('departments', {'name': department});
      }
    }

    return dbClient;
  }

  Future<List<Map<String, dynamic>>> getAssets() async {
    try {
      var dbClient = await db;
      return await dbClient.query('assets');
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  Future<Map<String, dynamic>?> getAssetByUid(String uid) async {
    try {
      var dbClient = await db;
      List<Map<String, dynamic>> results = await dbClient.query(
        'assets',
        where: 'uid = ?',
        whereArgs: [uid],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw Exception('Error fetching asset by UID $uid: $e');
    }
  }

  Future<void> insertNewAsset(
    String id,
    String category,
    String brand,
    String department,
    String uid,
    String date,
  ) async {
    try {
      var dbClient = await db;
      id = id.toUpperCase();
      uid = uid.toUpperCase();

      Map<String, dynamic> asset = {
        'id': id,
        'uid': uid,
        'category': category,
        'brand': brand,
        'department': department,
        'date': date,
        'status': 'Available',
      };

      await dbClient.insert(
        'assets',
        asset,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting data: $e');
    }
  }

  Future<void> deleteAllAssets() async {
    try {
      var dbClient = await db;
      await dbClient.delete('assets');
    } catch (e) {
      throw Exception('Error deleting all data: $e');
    }
  }

  Future<void> deleteAssetByUid(String uid) async {
    try {
      var dbClient = await db;
      await dbClient.delete('assets', where: 'uid = ?', whereArgs: [uid]);
    } catch (e) {
      throw Exception('Error deleting data with UID $uid: $e');
    }
  }

  Future<bool> updateStatus(String uid, String status) async {
    try {
      var dbClient = await db;
      Map<String, dynamic> updatedStatus = {'status': status};

      int count = await dbClient.update(
        'assets',
        updatedStatus,
        where: 'uid = ?',
        whereArgs: [uid],
      );

      return count > 0;
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  // เพิ่มเมธอดใหม่สำหรับอัปเดตข้อมูลสินทรัพย์ทั้งหมด
  Future<bool> updateAsset(
    String uid,
    String id,
    String category,
    String brand,
    String department,
    String status,
    String date,
  ) async {
    try {
      var dbClient = await db;

      // ทำให้ uid และ id เป็นตัวพิมพ์ใหญ่ทั้งหมดให้สอดคล้องกับการเพิ่มข้อมูลใหม่
      uid = uid.toUpperCase();
      id = id.toUpperCase();

      Map<String, dynamic> updatedAsset = {
        'id': id,
        'category': category,
        'brand': brand,
        'department': department,
        'status': status,
        'date': date,
      };

      int count = await dbClient.update(
        'assets',
        updatedAsset,
        where: 'uid = ?',
        whereArgs: [uid],
      );

      return count > 0;
    } catch (e) {
      print('Error updating asset: $e');
      return false;
    }
  }

  // ฟังก์ชันสำหรับจัดการหมวดหมู่
  Future<List<String>> getCategories() async {
    try {
      var dbClient = await db;
      List<Map<String, dynamic>> results = await dbClient.query(
        'categories',
        orderBy: 'name',
      );
      return results.map((map) => map['name'] as String).toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      var dbClient = await db;
      await dbClient.insert('categories', {'name': name});
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  Future<void> updateCategory(String oldName, String newName) async {
    try {
      var dbClient = await db;
      await dbClient.update(
        'categories',
        {'name': newName},
        where: 'name = ?',
        whereArgs: [oldName],
      );

      // อัปเดตรายการสินทรัพย์ที่ใช้หมวดหมู่นี้
      await dbClient.update(
        'assets',
        {'category': newName},
        where: 'category = ?',
        whereArgs: [oldName],
      );
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String name) async {
    try {
      var dbClient = await db;
      await dbClient.delete('categories', where: 'name = ?', whereArgs: [name]);
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }

  // ฟังก์ชันสำหรับจัดการแผนก
  Future<List<String>> getDepartments() async {
    try {
      var dbClient = await db;
      List<Map<String, dynamic>> results = await dbClient.query(
        'departments',
        orderBy: 'name',
      );
      return results.map((map) => map['name'] as String).toList();
    } catch (e) {
      throw Exception('Error fetching departments: $e');
    }
  }

  Future<void> addDepartment(String name) async {
    try {
      var dbClient = await db;
      await dbClient.insert('departments', {'name': name});
    } catch (e) {
      throw Exception('Error adding department: $e');
    }
  }

  Future<void> updateDepartment(String oldName, String newName) async {
    try {
      var dbClient = await db;
      await dbClient.update(
        'departments',
        {'name': newName},
        where: 'name = ?',
        whereArgs: [oldName],
      );

      // อัปเดตรายการสินทรัพย์ที่ใช้แผนกนี้
      await dbClient.update(
        'assets',
        {'department': newName},
        where: 'department = ?',
        whereArgs: [oldName],
      );
    } catch (e) {
      throw Exception('Error updating department: $e');
    }
  }

  Future<void> deleteDepartment(String name) async {
    try {
      var dbClient = await db;
      await dbClient.delete(
        'departments',
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      throw Exception('Error deleting department: $e');
    }
  }

  Future<String?> getRandomUid() async {
    try {
      var dbClient = await db; // ใช้ getter db ที่มีอยู่แล้ว
      List<Map<String, dynamic>> results = await dbClient.rawQuery(
        'SELECT uid FROM assets ORDER BY RANDOM() LIMIT 1',
      );

      if (results.isNotEmpty && results.first.containsKey('uid')) {
        return results.first['uid'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting random UID: $e');
      return null;
    }
  }
}
