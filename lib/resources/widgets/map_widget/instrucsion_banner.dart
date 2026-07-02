import 'package:flutter/material.dart';

class InstructionBanner extends StatelessWidget {
  const InstructionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc tròn chuẩn UI mẫu
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ), // Đổ bóng nhẹ sang chảnh
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min, // Thu gọn vừa bằng nội dung
        children: [
          Icon(
            Icons.info_outline, // Icon thông tin màu xanh
            color: Colors.lightBlue,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            "Nhấn giữ trên bản đồ để thêm thiên tai mới",
            style: TextStyle(
              fontSize: 14,
              //fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
