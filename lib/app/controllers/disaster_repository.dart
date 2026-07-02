import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nylo_framework/nylo_framework.dart';
import 'package:sqflite/sqflite.dart';
import '../models/disaster_type.dart';
import '../providers/database_helper.dart';

class DisasterRepository {
  // Giữ nguyên logic loadFile từ file gốc của bạn
  Future<List<DisasterType>> loadFile(BuildContext context) async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/json/disasters.json',
      );
      final List<dynamic> rawData = json.decode(jsonString);
      List<DisasterType> disasterTypes = rawData
          .map((item) => DisasterType.fromJson(item))
          .toList();

      final db = await DatabaseHelper.instance.database;
      Batch batch = db.batch();
      for (DisasterType type in disasterTypes) {
        batch.insert(
          'disaster_types',
          type.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      //print("Đọc json thành công");
      //showToastSuccess(description: "Đọc json thành công");
      // showToastNotification(
      //   context,
      //   id: "success",
      //   description: "Đọc json thành công",
      // );
      return disasterTypes;
    } catch (e) {
      //print("Lỗi đọc json hoặc DB: $e");
      showToastNotification(
        context,
        id: "danger",
        description: "Lỗi đọc json hoặc DB: $e",
      );

      return [];
    }
  }

  // Giữ nguyên logic getDisasterType
  Future<List<DisasterType>> getDisasterType(BuildContext context) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query('disaster_types');
      //print("=== SQLITE RAW DATA (Số lượng: ${maps.length}) ===");
      return List.generate(maps.length, (i) => DisasterType.fromJson(maps[i]));
    } catch (e) {
      showToastNotification(
        context,
        id: "danger",
        description: "Lỗi đọc dl từ sqlite: $e",
      );
      //print("Lỗi khi đọc dl từ sqlite: $e");
      return [];
    }
  }

  // Giữ nguyên logic saveReportedDisaster
  Future<bool> saveReportedDisaster(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final disasterType = data['disaster_type'] as DisasterType?;
      final pos = data['position'];

      await db.insert('reported_disasters', {
        'disaster_type_id': disasterType?.id,
        'title': data['title'],
        'description': data['description'],
        'latitude': pos.latitude.toStringAsFixed(3),
        'longitude': pos.longitude.toStringAsFixed(3),
        'image_path': data['image_path'],
        'create_time': data['create_time'],
        'update_time': data['update_time'],
      });
      return true;
    } catch (e) {
      //print("Lỗi khi lưu báo cáo xuống SQLite: $e");
      showToastNotification(
        context,
        id: "danger",
        description: "Lỗi lưu báo cáo: $e",
      );
      return false;
    }
  }

  // Hàm private hỗ trợ bóc tách imageBytes của bạn
  List<Map<String, dynamic>> _convertDbRows(List<Map<String, dynamic>> maps) {
    return maps.map((row) {
      final editableMap = Map<String, dynamic>.from(row);
      editableMap['image_path'] = row['image_path'] ?? '[]';
      if (editableMap['image'] != null) {
        try {
          editableMap['imageBytes'] = base64Decode(editableMap['image']);
        } catch (e) {
          editableMap['imageBytes'] = null;
        }
      }
      return editableMap;
    }).toList();
  }

  // Giữ nguyên logic getReportedDisasters
  Future<List<Map<String, dynamic>>> getReportedDisasters() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT r.*, t.name, t.image 
        FROM reported_disasters r
        LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
      ''');
      return _convertDbRows(maps);
    } catch (e) {
      print("Lỗi khi lấy danh sách báo cáo từ SQLite: $e");
      return [];
    }
  }

  // Giữ nguyên logic getReportedDisastersById
  Future<List<Map<String, dynamic>>> getReportedDisastersById(
    int? typeId,
  ) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT r.*, t.name, t.image 
        FROM reported_disasters r
        LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
        WHERE r.disaster_type_id = ?
      ''',
        [typeId],
      );
      return _convertDbRows(maps);
    } catch (e) {
      print("Lỗi khi lấy danh sách báo cáo từ SQLite: $e");
      return [];
    }
  }

  // Giữ nguyên logic searchDisaster
  Future<List<Map<String, dynamic>>> searchDisaster(String keyword) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final String searchKeyword = '%$keyword%';
      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
        SELECT r.*, t.name, t.image 
        FROM reported_disasters r
        LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
        WHERE (r.title LIKE ? OR r.description LIKE ? OR t.name LIKE ?)
      ''',
        [searchKeyword, searchKeyword, searchKeyword],
      );
      return _convertDbRows(results);
    } catch (e) {
      print("Lỗi khi tìm kiếm từ SQLite: $e");
      return [];
    }
  }

  // Giữ nguyên logic filterDisasters
  Future<List<Map<String, dynamic>>> filterDisasters(String sortType) async {
    try {
      final db = await DatabaseHelper.instance.database;
      String query = '''
        SELECT r.*, t.name, t.image 
        FROM reported_disasters r
        LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
      ''';

      switch (sortType) {
        case 'create_desc':
          query += ' ORDER BY r.create_time DESC';
          break;
        case 'create_asc':
          query += ' ORDER BY r.create_time ASC';
          break;
        case 'update_desc':
          query += ' ORDER BY r.update_time DESC';
          break;
        case 'alpha_asc':
          query += ' ORDER BY r.title COLLATE NOCASE ASC';
          break;
        default:
          query += ' ORDER BY r.create_time DESC';
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery(query);
      return _convertDbRows(maps);
    } catch (e) {
      print("Lỗi khi lọc danh sách từ SQLite: $e");
      return [];
    }
  }

  // Giữ nguyên logic deleteDisaster
  Future<int> deleteDisaster(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      return await db.delete(
        'reported_disasters',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Lỗi khi xóa thảm họa trong DB: $e");
      return 0;
    }
  }

  Future<bool> updateReportedDisaster(int id, Map<String, dynamic> data) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final disasterType = data['disaster_type'] as DisasterType?;

      int rowsUpdated = await db.update(
        'reported_disasters',
        {
          'disaster_type_id': disasterType?.id,
          'title': data['title'],
          'description': data['description'],
          'image_path':
              data['image_path'], // Cập nhật cả đường dẫn ảnh mới nếu có
          'update_time': data['update_time'],
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return rowsUpdated > 0;
    } catch (e) {
      print("Lỗi Repository (updateReportedDisaster): $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> sortReport() async {
    try {
      final db = await DatabaseHelper.instance.database;

      String query = '''
      SELECT r.*, t.name, t.image 
      FROM reported_disasters r
      LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
      ORDER BY r.update_time DESC
    ''';

      final List<Map<String, dynamic>> maps = await db.rawQuery(query);
      return _convertDbRows(maps);
      //return List.generate(maps.length, (i) => DisasterType.fromJson(maps[i]));
    } catch (e) {
      print("Lỗi khi đọc danh mục sắp xếp từ sqlite: $e");
      return [];
    }
  }
}
