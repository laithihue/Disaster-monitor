import 'package:disaster_app/app/controllers/disaster_controller.dart';
import 'package:flutter/material.dart';

//import '../../../app/controllers/disaster_repository.dart';

class DeleteMarker {
  final BuildContext context;
  final Map<String, dynamic> item;
  final DisasterController controller;

  DeleteMarker({
    required this.context,
    required this.item,
    required this.controller,
  });

  // Mục 1: Hàm hiển thị Dialog (Private bên trong class)
  //trả về lựa chọn của user
  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text(
            "Bạn có chắc chắn muốn xóa thảm họa '${item['title'] ?? ''}' không?",
          ),
          actions: [
            TextButton(
              child: const Text("Hủy"),
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Xóa", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
  }

  // Mục 2: Hàm thực thi logic xóa chính
  Future<void> execute() async {
    final int? id = item['id'];
    if (id == null) return;

    // Gọi hàm hiện dialog nội bộ
    final bool? isConfirmed = await _showConfirmDialog();

    if (isConfirmed == true) {
      // Gọi DB xóa
      bool isSuccess = await controller.deleteDisasterItem(id);

      if (isSuccess) {
        // Đóng BottomSheet (nếu có)
        if (context.mounted) Navigator.pop(context, 'deleted');

        // Hiển thị thông báo
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xóa thảm họa thành công")),
          );
        }
      } else {
        // Thông báo nếu có lỗi xảy ra ở tầng DB
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xóa thất bại, vui lòng thử lại")),
          );
        }
      }
    }
  }
}
