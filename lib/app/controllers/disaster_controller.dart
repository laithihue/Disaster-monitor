import 'package:nylo_framework/nylo_framework.dart';
import '../models/disaster_type.dart';
import '/app/controllers/controller.dart';
import 'disaster_repository.dart';

class DisasterController extends Controller {
  // Gọi lớp xử lý SQLite độc lập
  final DisasterRepository _repository = DisasterRepository();

  // GIỮ NGUYÊN HOÀN TOÀN TÊN CÁC BIẾN RAM CŨ CỦA BẠN
  List<DisasterType> disasterTypes = [];
  List<Map<String, dynamic>> disasters = [];
  List<Map<String, dynamic>> allDisasters = [];

  // 1. loadFile
  Future<void> loadFile(context) async {
    disasterTypes = await _repository.loadFile(context);
  }

  // 2. getDisasterType
  Future<List<DisasterType>> getDisasterType(context) async {
    disasterTypes = await _repository.getDisasterType(context);
    return disasterTypes;
  }

  // 3. saveReportedDisaster
  Future<bool> saveReportedDisaster(context, Map<String, dynamic> data) async {
    return await _repository.saveReportedDisaster(context, data);
  }

  // 4. fetchDisaster (Hàm nạp dữ liệu lên RAM và thông báo UI)
  Future<void> fetchDisaster(int? typeId) async {
    List<Map<String, dynamic>> result = [];

    if (typeId == -1) {
      result = await _repository.getReportedDisasters();
    } else {
      result = await _repository.getReportedDisastersById(typeId);
    }

    // Gán dữ liệu vào chính xác các tên biến cũ của bạn
    allDisasters = result;
    disasters = result;

    // Bắn thông báo cập nhật giao diện
    updateState('disaster_data_provider', data: result);
  }

  Future<void> fetchSortedReports() async {
    final data = await _repository.sortReport();
    this.disasters = data;
    updateState('disaster_data_provider', data: data);
  }

  // 5. executeSearch (Hàm xử lý tìm kiếm trên UI)
  Future<void> executeSearch(String query) async {
    if (query.trim().isEmpty) {
      disasters = allDisasters; // Trả về danh sách gốc cũ
      updateState('disaster_data_provider');
      return;
    }

    // Lưu kết quả tìm kiếm vào biến disasters hiển thị
    disasters = await _repository.searchDisaster(query.trim().toLowerCase());
    updateState('disaster_data_provider');
  }

  // 6. executeFilter (Hàm xử lý bộ lọc sắp xếp trên UI)
  Future<void> executeFilter(String sortType) async {
    disasters = await _repository.filterDisasters(sortType);
    updateState('disaster_data_provider');
  }

  // 7. deleteDisasterItem (Hàm thực thi xóa từ UI)
  Future<bool> deleteDisasterItem(int id) async {
    int rowsDeleted = await _repository.deleteDisaster(id);

    if (rowsDeleted > 0) {
      // Xóa đồng loạt trên cả 2 biến RAM cũ của bạn
      disasters.removeWhere((element) => element['id'] == id);
      allDisasters.removeWhere((element) => element['id'] == id);

      updateState(
        'disaster_data_provider',
      ); // Giật chuông báo UI biến mất phần tử
      return true;
    }
    return false;
  }

  Future<bool> updateReportedDisaster(int id, Map<String, dynamic> data) async {
    bool isSuccess = await _repository.updateReportedDisaster(id, data);
    if (isSuccess) {
      // Nạp lại dữ liệu mới nhất từ DB lên RAM
      await fetchDisaster(-1);
    }
    return isSuccess;
  }

  Future<List<Map<String, dynamic>>> sortReport() async {
    return await _repository.sortReport();
  }
}

// import 'dart:async';

// import 'package:flutter/services.dart' show rootBundle;
// import 'package:sqflite/sqflite.dart';
// import '../models/disaster_type.dart';
// import '../providers/database_helper.dart';
// import '/app/controllers/controller.dart';
// import 'dart:convert';

// class DisasterController extends Controller {
//   List<DisasterType> disasterTypes = [];
//   List<Map<String, dynamic>> disasters = [];
//   List<Map<String, dynamic>> allDisasters = [];

//   Future<void> loadFile() async {
//     try {
//       String jsonString = await rootBundle.loadString(
//         'assets/json/disasters.json',
//       );
//       final List<dynamic> rawData = json.decode(jsonString);
//       //.map trả về Iterable lặp qua từng phần tử của rawData, mỗi vòng lấy 1 phần tử đặt tên là item rồi cho vào khuôn Dis...fromJ
//       disasterTypes = rawData
//           .map((item) => DisasterType.fromJson(item))
//           .toList();
//       print("Đọc json thành công");

//       final db = await DatabaseHelper.instance.database; //kết nối
//       Batch batch = db.batch(); //gom lệnh ghi dl lại
//       for (DisasterType type in disasterTypes) {
//         //số lệnh insert = số thiên tai
//         batch.insert(
//           //xếp các câu lệnh vào hàng đợi
//           'disaster_types', //tên bảng
//           type.toJson(), //
//           conflictAlgorithm: ConflictAlgorithm
//               .replace, //xung đột khoá chính/ ràng bc thì thay cũ = mới
//         );
//       }
//       //lưu hàng loạt xuống bộ nhớ
//       await batch.commit(noResult: true); // noResult ko trả vê list id
//       print("Đồng bộ thành công ${disasterTypes.length} loại thiên tai");
//     } catch (e) {
//       print("Lỗi đọc json hoặc DB: $e");
//     }
//   }

//   Future<List<DisasterType>> getDisasterType() async {
//     try {
//       final db = await DatabaseHelper.instance.database; //kết nối
//       //truy vấn
//       final List<Map<String, dynamic>> maps = await db.query('disaster_types');

//       // 1. Kiểm tra xem SQLite có trả về dòng dữ liệu nào không
//       print("=== SQLITE RAW DATA (Số lượng: ${maps.length}) ===");

//       //Map -> obj
//       disasterTypes = List.generate(maps.length, (i) {
//         return DisasterType.fromJson(maps[i]);
//       });
//       return disasterTypes;
//     } catch (e) {
//       print("Lỗi khi đọc dl từ sqlite: $e");
//       return [];
//     }
//   }

//   //lưu báo cào
//   Future<bool> saveReportedDisaster(Map<String, dynamic> data) async {
//     try {
//       final db = await DatabaseHelper.instance.database; //kết nối
//       final disasterType = data['disaster_type'] as DisasterType?;
//       final pos = data['position']; // Kiểu LatLng

//       await db.insert('reported_disasters', {
//         'disaster_type_id': disasterType?.id,
//         'title': data['title'],
//         'description': data['description'],
//         'latitude': pos.latitude.toStringAsFixed(3),
//         'longitude': pos.longitude.toStringAsFixed(3),
//         //'image': data['image'],
//         'create_time': data['create_time'],
//         'update_time': data['update_time'],
//       });
//       return true;
//     } catch (e) {
//       print("Lỗi khi lưu báo cáo xuống SQLite: $e");
//       return false;
//     }
//   }

//   //đọc báo cao
//   Future<List<Map<String, dynamic>>> getReportedDisasters() async {
//     try {
//       final db = await DatabaseHelper.instance.database;

//       // Sử dụng câu lệnh lồng INNER JOIN để bốc luôn thông tin ảnh Base64 từ bảng loại thiên tai gốc
//       final List<Map<String, dynamic>> maps = await db.rawQuery('''
//       SELECT r.*, t.name, t.image 
//       FROM reported_disasters r
//       LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
      
//     ''');
//       //láy ra tất tất cả cột của bảng report lấy name namname, image của distype
//       //liên kết re vs dis đặt tên là r, với dk trungf id

//       // Chuyển đổi dữ liệu từ dạng bảng SQLite quay về dạng Map mà MapWidget đang cần dùn
//       return maps.map((row) {
//         // Tạo một map mới có thể chỉnh sửa (vì row từ db là read-only)
//         final editableMap = Map<String, dynamic>.from(row);

//         // Chuyển chuỗi image (Base64) sang Uint8List nếu có
//         if (editableMap['image'] != null) {
//           try {
//             editableMap['imageBytes'] = base64Decode(editableMap['image']);
//           } catch (e) {
//             editableMap['imageBytes'] = null;
//           }
//         }
//         return editableMap;
//       }).toList();
//     } catch (e) {
//       print("Lỗi khi lấy danh sách báo cáo từ SQLite: $e");
//       return [];
//     }
//   }

//   Future<List<Map<String, dynamic>>> getReportedDisastersById(
//     int? typeId,
//   ) async {
//     try {
//       final db = await DatabaseHelper.instance.database;

//       // Sử dụng câu lệnh lồng INNER JOIN để bốc luôn thông tin ảnh Base64 từ bảng loại thiên tai gốc
//       final List<Map<String, dynamic>> maps = await db.rawQuery(
//         '''
//       SELECT r.*, t.name, t.image 
//       FROM reported_disasters r
//       LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
//       WHERE r.disaster_type_id = ?
      
//     ''',
//         [typeId],
//       );
//       //láy ra tất tất cả cột của bảng report lấy name namname, image của distype
//       //liên kết re vs dis đặt tên là r, với dk trungf id

//       // Chuyển đổi dữ liệu từ dạng bảng SQLite quay về dạng Map mà MapWidget đang cần dùn
//       return maps.map((row) {
//         // Tạo một map mới có thể chỉnh sửa (vì row từ db là read-only)
//         final editableMap = Map<String, dynamic>.from(row);

//         // Chuyển chuỗi image (Base64) sang Uint8List nếu có
//         if (editableMap['image'] != null) {
//           try {
//             editableMap['imageBytes'] = base64Decode(editableMap['image']);
//           } catch (e) {
//             editableMap['imageBytes'] = null;
//           }
//         }
//         return editableMap;
//       }).toList();
//     } catch (e) {
//       print("Lỗi khi lấy danh sách báo cáo từ SQLite: $e");
//       return [];
//     }
//   }

//   Future<List<Map<String, dynamic>>> searchDisaster(String keyword) async {
//     final db = await DatabaseHelper.instance.database;
//     final String searchKeyword = '%$keyword%';

//     final List<Map<String, dynamic>> results = await db.rawQuery(
//       '''
//     SELECT r.*, t.name, t.image 
//     FROM reported_disasters r
//     LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
//     WHERE (
//         r.title LIKE ? 
//         OR r.description LIKE ? 
//         OR t.name LIKE ?
//     )
//   ''',
//       [searchKeyword, searchKeyword, searchKeyword],
//     ); // Truyền 3 lần cho 3 dấu chấm hỏi
//     //return results;
//     return results.map((row) {
//       // Tạo một map mới có thể chỉnh sửa (vì row từ db là read-only)
//       final editableMap = Map<String, dynamic>.from(row);

//       // Chuyển chuỗi image (Base64) sang Uint8List nếu có
//       if (editableMap['image'] != null) {
//         try {
//           editableMap['imageBytes'] = base64Decode(editableMap['image']);
//         } catch (e) {
//           editableMap['imageBytes'] = null;
//         }
//       }
//       return editableMap;
//     }).toList();
//   }

//   Future<List<Map<String, dynamic>>> filterDisasters(
//     String sortType,
//     //int? typeId,
//   ) async {
//     try {
//       final db = await DatabaseHelper.instance.database;

//       // 1. Khởi tạo câu lệnh SQL gốc kết hợp LEFT JOIN
//       String query = '''
//       SELECT r.*, t.name, t.image 
//       FROM reported_disasters r
//       LEFT JOIN disaster_types t ON r.disaster_type_id = t.id
//     ''';

//       List<dynamic> whereArgs = [];

//       // 2. Nếu có lọc theo Loại thiên tai cụ thể (typeId khác -1 hoặc null)
//       //if (typeId != null && typeId != -1) {
//       //query += ' WHERE r.disaster_type_id = ?';
//       //whereArgs.add(typeId);
//       //}

//       // 3. THÊM MỆNH ĐỀ ORDER BY DỰA VÀO SORT TYPE
//       switch (sortType) {
//         case 'create_desc': // Ngày tạo: Mới nhất lên đầu
//           query += ' ORDER BY r.create_time DESC';
//           break;
//         case 'create_asc': // Ngày tạo: Cũ nhất lên đầu
//           query += ' ORDER BY r.create_time ASC';
//           break;
//         case 'update_desc': // Cập nhật lần cuối: Mới nhất lên đầu
//           query += ' ORDER BY r.update_time DESC';
//           break;
//         case 'alpha_asc': // Tiêu đề: Sắp xếp từ A đến Z
//           query +=
//               ' ORDER BY r.title COLLATE NOCASE ASC'; // NOCASE để không phân biệt chữ hoa/thường
//           break;
//         default: // Mặc định sắp xếp theo ngày tạo mới nhất
//           query += ' ORDER BY r.create_time DESC';
//       }

//       final List<Map<String, dynamic>> maps = await db.rawQuery(
//         query,
//         whereArgs,
//       );

//       // 4. Biến đổi dữ liệu sang dạng Map có chứa 'imageBytes' giống hàm trước của bạn
//       return maps.map((row) {
//         final editableMap = Map<String, dynamic>.from(row);
//         if (editableMap['image'] != null) {
//           try {
//             editableMap['imageBytes'] = base64Decode(editableMap['image']);
//           } catch (e) {
//             editableMap['imageBytes'] = null;
//           }
//         }
//         return editableMap;
//       }).toList();
//     } catch (e) {
//       print("Lỗi khi lọc danh sách từ SQLite: $e");
//       return [];
//     }
//   }

//   Future<int> deleteDisaster(int id) async {
//     try {
//       final db = await DatabaseHelper.instance.database;

//       // Thực thi lệnh xóa bản ghi có id trùng khớp
//       int count = await db.delete(
//         'reported_disasters',
//         where: 'id = ?',
//         whereArgs: [id],
//       );

//       return count; // Trả về số lượng bản ghi đã xóa (thường là 1 nếu thành công)
//     } catch (e) {
//       print("Lỗi khi xóa thảm họa trong DB: $e");
//       return 0;
//     }
//   }
//   //tải dl
//   Future<void> fetchDisaster(int? typeId) async {
//     List<Map<String, dynamic>> result = [];
    
//     if (typeId == -1) {
//       result = await getReportedDisasters();
//     } else {
//       result = await getReportedDisastersById(typeId);
//     }

//     // Cập nhật dữ liệu vào bộ nhớ RAM của Controller
//     allDisasters = result;
//     disasters = result;

//     // Bắn thông báo cập nhật trạng thái UI với key định danh
//     updateState('disaster_data_provider');
//   }
//   Future<bool> deleteDisasterItem(int id) async {
//     // Bước A: Gọi xuống DB thực hiện xóa dòng dữ liệu vật lý
//     int rowsDeleted = await deleteDisaster(id);
    
//     if (rowsDeleted > 0) {
//       // Bước B: Xóa trực tiếp trên các danh sách RAM đang quản lý
//       disasters.removeWhere((element) => element['id'] == id);
//       allDisasters.removeWhere((element) => element['id'] == id);
      
//       // Bước C: Bắn thông báo để tất cả UI đang hiển thị tự động biến mất Marker/Card đó
//       updateState('disaster_data_provider');
//       return true;
//     }
//     return false;
//   }
// }
