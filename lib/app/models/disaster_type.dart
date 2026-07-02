import 'dart:convert';
import 'dart:typed_data';

import 'package:nylo_framework/nylo_framework.dart';

class DisasterType extends Model {
  late int? id;
  String? nameDisaster;
  String? image;

  DisasterType({this.id, this.nameDisaster, this.image});

  // Hàm này Nylo tự tạo khung, bạn chỉ cần điền các key từ json vào
  DisasterType.fromJson(dynamic json) {
    id = json['id'];
    nameDisaster = json['name_disaster'] ?? json['name'];
    image = json['image'];
  }

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "name": nameDisaster,
    "image": image,
  };

  Uint8List? get imageBytes {
    if (image == null || image!.isEmpty) return null;
    return base64Decode(image!);
  }
}
//image định dạng svg
//base64: chuỗi ASCII để truyền tải qua văn bản, nhúng vào API/html
//uint8...: mảng các số nguyên từ 0-255, thao tác đọc ghi dữ liệu nhị phân