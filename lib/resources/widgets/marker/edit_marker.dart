import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../app/controllers/disaster_controller.dart';
import '../../../app/forms/form_widget.dart'; // Thay đổi đường dẫn đúng với dự án của bạn

class EditMarker {
  final BuildContext context;
  final Map<String, dynamic> item; // Dữ liệu thảm họa cũ hiện tại
  final LatLng position; // Tọa độ hiện tại của thảm họa
  final DisasterController controller; // Thực thể controller dùng chung

  EditMarker({
    required this.context,
    required this.item,
    required this.position,
    required this.controller,
  });

  Future<void> execute() async {
    final int? id = item['id'];
    if (id == null) return;

    // 1. Đóng BottomSheet chi tiết hiện tại lại trước
    //Navigator.pop(context);

    // 2. Mở FormWidget lên ở chế độ Sửa (truyền kèm tham số editData)
    final updatedResult = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FormWidget(
        position: position,
        editData: item, // Ném toàn bộ cục dữ liệu Map cũ sang để điền sẵn form
      ),
    );

    // 3. Nếu user sửa xong và bấm nút "Cập nhật" (Form trả về dữ liệu mới)
    if (updatedResult == true) {
      // Gọi Controller thực hiện cập nhật đè xuống SQLite và làm mới RAM
      //await controller.updateReportedDisaster(id, updatedResult);
      Navigator.pop(context, true);
    }
  }
}
