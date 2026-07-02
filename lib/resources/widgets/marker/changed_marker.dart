import 'package:flutter/material.dart';

class ChangedMarker extends StatelessWidget {
  // Định nghĩa các hàm callback để hứng sự kiện từ màn hình cha truyền vào
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onDirectionsPressed;

  const ChangedMarker({
    super.key,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onDirectionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. NÚT SỬA
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onEditPressed, // Kích hoạt hàm truyền từ bên ngoài
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                "Sửa",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. NÚT XÓA
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red[700],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onDeletePressed, // Kích hoạt hàm truyền từ bên ngoài
              icon: const Icon(Icons.delete_forever, size: 18),
              label: const Text(
                "Xóa",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 3. NÚT ĐƯỜNG DẪN
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  onDirectionsPressed, // Kích hoạt hàm truyền từ bên ngoài
              icon: const Icon(Icons.directions, size: 18),
              label: const Text(
                "Chỉ dẫn",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
